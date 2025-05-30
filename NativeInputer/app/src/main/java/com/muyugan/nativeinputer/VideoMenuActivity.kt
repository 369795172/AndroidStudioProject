package com.muyugan.nativeinputer

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.muyugan.nativeinputer.ui.theme.NativeInputerTheme

class VideoMenuActivity : ComponentActivity() {
    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            NativeInputerTheme {
                Scaffold(
                    topBar = {
                        CenterAlignedTopAppBar(
                            title = { Text("看视频") },
                            navigationIcon = {
                                IconButton(onClick = { finish() }) {
                                    Icon(Icons.Filled.ArrowBack, contentDescription = "返回")
                                }
                            }
                        )
                    }
                ) { paddingValues ->
                    Surface(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(paddingValues)
                    ) {
                        VideoMenuContent { videoId, level ->
                            // Handle video click - start VideoPlayerActivity
                            startActivity(
                                Intent(this@VideoMenuActivity, VideoPlayerActivity::class.java).apply {
                                    putExtra("level", level)
                                    putExtra("videoId", videoId)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoMenuContent(onClick: (String, Int) -> Unit) {
    // State management
    var selectedLevel by remember { mutableStateOf("全部等级") }
    var selectedType by remember { mutableStateOf("全部类型") }
    var selectedTag by remember { mutableStateOf("全部标签") }
    var searchQuery by remember { mutableStateOf("") }
    var searchActive by remember { mutableStateOf(false) }

    // Sample data
    val allVideos = remember { generateSampleVideos() }
    val lastPlayedVideo = remember { getLastPlayedVideo() }

    // Filter and search logic
    val filteredVideos = remember(selectedLevel, selectedType, selectedTag, searchQuery) {
        allVideos.filter { video ->
            val levelMatch = selectedLevel == "全部等级" || video.level.toString() == selectedLevel.replace("等级", "").trim()
            val typeMatch = selectedType == "全部类型" || video.type == selectedType
            val tagMatch = selectedTag == "全部标签" || video.tags.contains(selectedTag)
            val searchMatch = searchQuery.isEmpty() || 
                video.title.contains(searchQuery, ignoreCase = true) ||
                video.description.contains(searchQuery, ignoreCase = true)
            
            levelMatch && typeMatch && tagMatch && searchMatch
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Filter and Search Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Level Filter
            FilterDropdown(
                label = "等级",
                selectedValue = selectedLevel,
                options = listOf("全部等级", "等级 1", "等级 2", "等级 3", "等级 4", "等级 5"),
                onValueSelected = { selectedLevel = it },
                modifier = Modifier.weight(1f)
            )
            
            Spacer(modifier = Modifier.width(8.dp))
            
            // Type Filter
            FilterDropdown(
                label = "类型",
                selectedValue = selectedType,
                options = listOf("全部类型", "儿歌", "故事", "英语", "数学", "科学"),
                onValueSelected = { selectedType = it },
                modifier = Modifier.weight(1f)
            )
            
            Spacer(modifier = Modifier.width(8.dp))
            
            // Tag Filter
            FilterDropdown(
                label = "标签",
                selectedValue = selectedTag,
                options = listOf("全部标签", "动画", "互动", "教育", "娱乐", "经典"),
                onValueSelected = { selectedTag = it },
                modifier = Modifier.weight(1f)
            )
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Search Bar
            SearchBar(
                query = searchQuery,
                onQueryChange = { searchQuery = it },
                onSearch = { searchActive = false },
                active = searchActive,
                onActiveChange = { searchActive = it },
                placeholder = { Text("搜索课程") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = "搜索") },
                modifier = Modifier.weight(2f)
            ) {
                // Search suggestions can be added here
            }
        }

        // Last Played Video Section
        lastPlayedVideo?.let { video ->
            LastPlayedVideoCard(
                video = video,
                onPlayClick = { onClick(video.videoId, 1) }, // Default level
                onPlaylistClick = { /* Show playlist */ },
                modifier = Modifier.padding(bottom = 16.dp)
            )
        }

        // Video List
        Text(
            text = "课程列表 (${filteredVideos.size})",
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(filteredVideos) { video ->
                VideoListItem(
                    video = video,
                    onClick = { onClick(video.id, video.level) }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterDropdown(
    label: String,
    selectedValue: String,
    options: List<String>,
    onValueSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = selectedValue,
            onValueChange = {},
            readOnly = true,
            label = { Text(label) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = Modifier
                .menuAnchor()
                .fillMaxWidth(),
            textStyle = MaterialTheme.typography.bodySmall
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(option) },
                    onClick = {
                        onValueSelected(option)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
fun LastPlayedVideoCard(
    video: LastPlayedVideo,
    onPlayClick: () -> Unit,
    onPlaylistClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onPlayClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Thumbnail placeholder
            Card(
                modifier = Modifier.size(80.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.PlayArrow,
                        contentDescription = "播放",
                        modifier = Modifier.size(32.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "继续观看",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary
                )
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                LinearProgressIndicator(
                    progress = video.progress,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            IconButton(onClick = onPlaylistClick) {
                Icon(
                    Icons.Default.PlaylistPlay,
                    contentDescription = "播放目录"
                )
            }
        }
    }
}

@Composable
fun VideoListItem(
    video: VideoItem,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Thumbnail placeholder
            Card(
                modifier = Modifier.size(60.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.VideoLibrary,
                        contentDescription = "视频",
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleSmall,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                if (video.description.isNotEmpty()) {
                    Text(
                        text = video.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
                
                // Tags and metadata
                Row(
                    modifier = Modifier.padding(top = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    AssistChip(
                        onClick = { },
                        label = { Text("等级${video.level}") }
                    )
                    AssistChip(
                        onClick = { },
                        label = { Text(video.type) }
                    )
                    if (video.tags.isNotEmpty()) {
                        AssistChip(
                            onClick = { },
                            label = { Text(video.tags.first()) }
                        )
                    }
                }
            }
            
            Icon(
                Icons.Default.PlayArrow,
                contentDescription = "播放",
                tint = MaterialTheme.colorScheme.primary
            )
        }
    }
}

// Enhanced data classes
data class VideoItem(
    val id: String,
    val title: String, 
    val thumbnailUrl: String = "",
    val level: Int,
    val type: String,
    val tags: List<String>,
    val description: String = ""
)

data class LastPlayedVideo(
    val videoId: String,
    val title: String,
    val thumbnailUrl: String = "",
    val progress: Float // 播放进度 0.0-1.0
)

// Sample data generation
fun generateSampleVideos(): List<VideoItem> {
    return listOf(
        VideoItem(
            id = "video1",
            title = "小兔子乖乖",
            level = 1,
            type = "儿歌",
            tags = listOf("动画", "经典"),
            description = "经典儿歌，适合幼儿学习"
        ),
        VideoItem(
            id = "video2", 
            title = "三只小猪的故事",
            level = 2,
            type = "故事",
            tags = listOf("教育", "互动"),
            description = "寓教于乐的经典童话故事"
        ),
        VideoItem(
            id = "video3",
            title = "ABC字母歌",
            level = 1,
            type = "英语",
            tags = listOf("动画", "教育"),
            description = "学习英语字母的最佳入门"
        ),
        VideoItem(
            id = "video4",
            title = "数字1到10",
            level = 1,
            type = "数学",
            tags = listOf("互动", "教育"),
            description = "学习基础数字认知"
        ),
        VideoItem(
            id = "video5",
            title = "太阳系的奥秘",
            level = 4,
            type = "科学",
            tags = listOf("教育", "娱乐"),
            description = "探索神奇的太阳系知识"
        ),
        VideoItem(
            id = "video6",
            title = "小红帽",
            level = 2,
            type = "故事",
            tags = listOf("经典", "动画"),
            description = "格林童话经典故事"
        ),
        VideoItem(
            id = "video7",
            title = "颜色认知歌",
            level = 1,
            type = "儿歌",
            tags = listOf("互动", "教育"),
            description = "通过歌曲学习各种颜色"
        ),
        VideoItem(
            id = "video8",
            title = "动物朋友们",
            level = 3,
            type = "科学",
            tags = listOf("动画", "教育"),
            description = "认识可爱的动物朋友"
        )
    )
}

fun getLastPlayedVideo(): LastPlayedVideo? {
    // Placeholder: In a real app, retrieve from SharedPreferences/DataStore
    return LastPlayedVideo(
        videoId = "video2",
        title = "三只小猪的故事",
        progress = 0.65f
    )
} 