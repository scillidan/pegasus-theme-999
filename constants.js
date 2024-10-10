.pragma library

const
    FOREGROUND_LIGHT = "#ffffff",

//MAIN COLOURS LIST
    AVAILABLE_COLOURS = [
	    '海鸥沙滩',
		'原神可莉',
		'赛博朋克',
		'全息舞女',
		'极致复古',
		'流浪地球',
 
    ],

	    海鸥沙滩 = "1",
		原神可莉 = "2",
		赛博朋克 = "3",
		全息舞女 = "4",
		极致复古 = "5",
		流浪地球 = "6",
 
    
    DEFAULT_MAIN_COLOUR = '极致复古',
    
//MAIN sound LIST
	AVAILABLE_SOUNDS = [
		'_8BIT_',
		'主题音乐',
		'全部静音',
		],

		_8BIT_ = "1",
		主题音乐 = "2",
		全部静音 = "3",
	
	DEFAULT_MAIN_SOUND = '主题音乐',
	
//MAIN TEXTSIZE
	AVAILABLE_TEXTSIZES = [
		'列表10个',
		'列表15个',
		'列表20个',
		],

		列表10个 = 1,
		列表15个 = 2,
		列表20个 = 3,
	
	DEFAULT_MAIN_TEXTSIZE = '列表20个',

//MAIN TEXTSTYLE
	AVAILABLE_TEXTSTYLES = [
		'全小素',
		'方舟像素等宽',
		'观致',
		'文泉驿点阵宋体',
		'寒蝉点阵体',
		],
		
		全小素 = "fonts/quan.ttf",
		方舟像素等宽 = "fonts/ark-pixel-12px-monospaced-zh_cn.ttf",
		观致 = "fonts/GuanZhi-8px.ttf",
		文泉驿点阵宋体 = "fonts/WenQuanYi Bitmap Song 12px.ttf",
		寒蝉点阵体 = "fonts/ChillBitmap_7px.ttf",
	
	DEFAULT_MAIN_TEXTSTYLE = '全小素',
	
//MAIN BACKSOUND
	AVAILABLE_BACKSOUNDS = [
		'后台静音',
		'后台音乐',
		],
		
		后台静音 = "true",
		后台音乐 = "false",
	
	DEFAULT_MAIN_BACKSOUND = '后台静音',
	
//MAIN TIP
	AVAILABLE_TIPS = [
		'简介显示',
		'简介关闭',
		],
		
		简介显示 = 1,
		简介关闭 = 0,
	
	DEFAULT_MAIN_TIP = '简介显示',

//MAIN TOPS
		AVAILABLE_TOPS = [
		'顶栏黑色',
		'顶栏白色',
		],
		
		顶栏黑色 = "ES2-logo-B",
		顶栏白色 = "ES2-logo-W",
	
	DEFAULT_MAIN_TOP = '顶栏黑色',
	
	
// api.memory keys used
    MAIN_COLOUR = 'main_colour',
	MAIN_SOUND = 'main_sound',
	MAIN_TEXTSIZE = 'main_textsize',
	MAIN_TEXTSTYLE = 'main_textstyle',
	MAIN_BACKSOUND = 'main_backsound',
	MAIN_TIP = 'main_tip',
	MAIN_TOP = 'main_top',
    HIDE_SUPPORT = 'hide_support'
