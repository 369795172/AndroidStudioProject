package com.muyugan.nativeinputer

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material.icons.filled.SportsEsports
import androidx.compose.material.icons.filled.VideoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.muyugan.nativeinputer.ui.theme.NativeInputerTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            NativeInputerTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    SwitchStyleHomePage()
                }
            }
        }
    }
}

@Composable
fun SwitchStyleHomePage() {
    val context = LocalContext.current
    
    // 定义卡片数据
    val gameCards = listOf(
        GameCard("看视频", Icons.Filled.VideoLibrary, 0),
        GameCard("听音频", Icons.Filled.Mic, 1),
        GameCard("玩游戏", Icons.Filled.SportsEsports, 2),
        GameCard("AI交互", Icons.Filled.SmartToy, 3)
    )

    // 使用Box来实现垂直居中布局
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // 标题区域
            Text(
                text = "应用主页",
                style = MaterialTheme.typography.headlineLarge,
                modifier = Modifier.padding(bottom = 32.dp),
                color = MaterialTheme.colorScheme.onSurface
            )
            
            // Nintendo Switch风格的水平卡片列表
            LazyRow(
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(horizontal = 24.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                items(count = gameCards.size) { index ->
                    val card = gameCards[index]
                    SwitchGameCard(
                        title = card.title,
                        icon = card.icon,
                        onClick = {
                            // 导航逻辑：只有"看视频"跳转到VideoMenuActivity，其他跳转到TBDActivity
                            val intent = when (card.id) {
                                0 -> Intent(context, VideoMenuActivity::class.java)
                                else -> Intent(context, TBDActivity::class.java)
                            }
                            context.startActivity(intent)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun SwitchGameCard(
    title: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    // 计算自适应尺寸：屏幕宽度的25%作为卡片宽度，保持Switch卡片的宽高比
    BoxWithConstraints {
        val cardWidth = (maxWidth * 0.25f).coerceAtLeast(220.dp).coerceAtMost(320.dp)
        val cardHeight = cardWidth * 0.7f // 保持Switch卡片的比例
        
        Card(
            onClick = onClick,
            modifier = Modifier
                .width(cardWidth)
                .height(cardHeight),
            shape = RoundedCornerShape(12.dp),
            elevation = CardDefaults.elevatedCardElevation(defaultElevation = 6.dp),
            colors = CardDefaults.elevatedCardColors(
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.onSurface
            )
        ) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    // 游戏图标 - 大小也根据卡片尺寸调整
                    Icon(
                        imageVector = icon,
                        contentDescription = title,
                        modifier = Modifier.size((cardWidth * 0.25f).coerceAtLeast(48.dp).coerceAtMost(80.dp)),
                        tint = MaterialTheme.colorScheme.primary
                    )
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    // 游戏标题
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleMedium,
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            }
        }
    }
}

// 数据类定义游戏卡片
data class GameCard(
    val title: String,
    val icon: ImageVector,
    val id: Int
)