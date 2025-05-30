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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import coil.compose.AsyncImage
import androidx.compose.foundation.background

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
            FeaturedVideoPlayerView(
                video = video,
                onPlayClick = { onClick(video.videoId, 1) }, // Default level, adjust as needed
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp) // 固定高度，更紧凑
                    .padding(bottom = 16.dp)
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
fun FeaturedVideoPlayerView(
    video: LastPlayedVideo,
    onPlayClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onPlayClick,
        modifier = modifier
            .clip(MaterialTheme.shapes.medium),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Left: Thumbnail with play overlay
            Box(
                modifier = Modifier
                    .size(96.dp)
                    .clip(MaterialTheme.shapes.small),
                contentAlignment = Alignment.Center
            ) {
                // Thumbnail
                AsyncImage(
                    model = video.thumbnailUrl.ifEmpty { R.drawable.ic_launcher_background },
                    contentDescription = video.title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
                
                // Play Button Overlay
                Icon(
                    imageVector = Icons.Filled.PlayCircleFilled,
                    contentDescription = "Play Video",
                    tint = Color.White.copy(alpha = 0.9f),
                    modifier = Modifier.size(32.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Right: Video info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = "继续观看",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(8.dp))
                
                // Progress bar
                LinearProgressIndicator(
                    progress = video.progress,
                    modifier = Modifier.fillMaxWidth(),
                    trackColor = MaterialTheme.colorScheme.surfaceVariant
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "已观看 ${(video.progress * 100).toInt()}%",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Right arrow
            Icon(
                imageVector = Icons.Filled.ChevronRight,
                contentDescription = "播放",
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(24.dp)
            )
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
        modifier = modifier
            .fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Thumbnail Placeholder (Replace with actual image loading if needed)
            Icon(
                imageVector = Icons.Filled.VideoLibrary,
                contentDescription = "Video Thumbnail",
                modifier = Modifier
                    .size(80.dp)
                    .padding(end = 8.dp),
                tint = MaterialTheme.colorScheme.secondary
            )
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = video.description.ifEmpty { "点击查看详情" },
                    style = MaterialTheme.typography.bodySmall,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    AssistChip(onClick = { /* Filter by level */ }, label = { Text("等级 ${video.level}") })
                    AssistChip(onClick = { /* Filter by type */ }, label = { Text(video.type) })
                    video.tags.take(2).forEach { tag -> // Show max 2 tags
                        AssistChip(onClick = { /* Filter by tag */ }, label = { Text(tag) })
                    }
                }
            }
            Icon(
                imageVector = Icons.Filled.ChevronRight,
                contentDescription = "Play",
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