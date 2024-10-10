// import QtQuick 2.0
import QtQuick 2.15
// import QtMultimedia 5.9
import SortFilterProxyModel 0.2
import QtQuick.Layouts 1.11
// import QtMultimedia 5.8
import QtMultimedia 5.15
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS
import "resources" as Resources


FocusScope {
    readonly property real scale: Math.min(width / 960.0, height / 720.0)


	Resources.Music { id: music
	}
	
	SortFilterProxyModel {
        id: allFavorites
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "favorite"; value: true; }
		// sorters: RoleSorter { roleName: "collections"; sortOrder: Qt.DescendingOrder; }
		
    }
    SortFilterProxyModel {
        id: allLastPlayed
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "lastPlayed"; value: ""; inverted: true; }
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }
    SortFilterProxyModel {
        id: filterLastPlayed
        sourceModel: allLastPlayed
        filters: IndexFilter { maximumIndex: {
            if (allLastPlayed.count >= 49) return 49
            return allLastPlayed.count
        } }
    }
	
    property var allCollections: {
       const collections = api.collections.toVarArray()
       collections.unshift({"name": "收藏游戏", "shortName": "收藏游戏", "games": allFavorites})
       collections.unshift({"name": "最近游戏", "shortName": "最近游戏", "games": filterLastPlayed})
       collections.unshift({"name": "全部游戏", "shortName": "全部游戏", "games": api.allGames})
        return collections
    }

    function scaled(value) {
        return scale * value;
    }
  
	SoundEffect {
        id: forwardSound;
        source: 'sounds/cursor1.wav';
        volume: 0.1;
    }
	
	SoundEffect {
        id: nextSound;
        source: 'sounds/cursor2.wav';
        volume: 0.2;
    }
  

    function zeroPad(number, width) {
        var str = number.toString();
        var strlen = str.length;
        if (strlen >= width)
            return str;

        return new Array(width - strlen + 1).join('0') + number;
    }

    function modulo(a, n) {
        return (a % n + n) % n;
    }

    function nextCollection() {
        if(collectionIdx==allCollections.length-1){collectionIdx = 0;return}
		else {collectionIdx = Math.min(collectionIdx + 1, allCollections.length-1);}
    }
    function prevCollection() {
		if(collectionIdx==0){collectionIdx = allCollections.length-1;return}
        else {collectionIdx = Math.max(collectionIdx - 1, 0);}
    }

    function launchGame(game) {
        api.memory.set('collectionIndex', collectionIdx);
        api.memory.set('gameIndex', gamelist.currentIndex);
        game.launch();
    }
	
	function updateTextsize() {
        api.memory.set(CONSTANTS.MAIN_TEXTSIZE, itemTextsize.value);
		nextCollection();
		prevCollection()
    }
	
	function updateTextstyle() {
        api.memory.set(CONSTANTS.MAIN_TEXTSTYLE, itemTextstyle.value);
    }
	
	function updateBacksound() {
        api.memory.set(CONSTANTS.MAIN_BACKSOUND, itemBacksound.value)
    }
	
	function updateTip() {
        api.memory.set(CONSTANTS.MAIN_TIP, itemTip.value);
    }
	
	function updateColour() {
        api.memory.set(CONSTANTS.MAIN_COLOUR, itemColour.value);
    }
	
	function updateSound() {
        api.memory.set(CONSTANTS.MAIN_SOUND, itemSound.value);
    }

    property int collectionIdx: api.memory.get('collectionIndex') || 0
	property var currentCollection
	property var colidx: collectionIdx+1
	property var currentGameIdx: gamelist.currentIndex+1
    readonly property var collection: allCollections[collectionIdx] || allCollections[0]//api.collections.get(collectionIdx) || api.collections.get(0)

    Keys.onLeftPressed: {
				if(flickable.contentHeight > flickable.height){
			flickable.contentY = flickable.contentY-vpx(30);
			if(flickable.contentY < -flickable.topMargin) {
				flickable.contentY = -flickable.topMargin
			}
		}
	}
	
	// prevCollection()
    Keys.onRightPressed: {
				if(flickable.contentHeight > flickable.height){
			flickable.contentY = flickable.contentY+vpx(30);
			if(flickable.contentY > flickable.contentHeight-flickable.height+flickable.bottomMargin){
				flickable.contentY = flickable.contentHeight-flickable.height+flickable.bottomMargin
			}
		}
	}
		
	
	// nextCollection()

	Keys.onPressed: {
		
			if (api.keys.isDetails(event) && !event.isAutoRepeat) {
						event.accepted = true;
						nextSound.play()
						if(itemTextsize.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus || itemTip.activeFocus ||  itemColour.activeFocus ||  itemSound.activeFocus){return gamelist.focus = true;}
						else {return itemColour.focus = true;}
						return;
					}
			if (api.keys.isFilters(event) && !event.isAutoRepeat) {
						event.accepted = true;
						
						if(itemTextsize.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus || itemTip.activeFocus ||  itemColour.activeFocus ||  itemSound.activeFocus){gamelist.focus = true;return}
			
						if(collectionIdx == 1){
								api.allGames.get(allLastPlayed.mapToSource(currentGameIdx-1)).favorite=!api.allGames.get(allLastPlayed.mapToSource(currentGameIdx-1)).favorite;
								return;
							}
						if(collectionIdx == 2){
									api.allGames.get(allFavorites.mapToSource(currentGameIdx-1)).favorite=!api.allGames.get(allFavorites.mapToSource(currentGameIdx-1)).favorite;
									return;
								}
						collection.games.get(currentGameIdx-1).favorite = ! collection.games.get(currentGameIdx-1).favorite;
						
						// nextSound.play()
						// if(itemTextsize.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus || itemTip.activeFocus ||  itemColour.activeFocus ||  itemSound.activeFocus){return gamelist.focus = true;}
						// else {return itemSound.focus = true;}
						
						// return;
					}

	}

    Component.onCompleted: {
        if(api.memory.has('gameIndex')){return gamelist.currentIndex = api.memory.get('gameIndex')}
		else {return gamelist.currentIndex = 0;}
    }


    FontLoader { id: subtitleFont; source: CONFIGS.getMainTextstyle(api)}
	
	property bool isPlaying: {
        return backMusic.playbackState === Audio.PlayingState;
    }
	
	
	Connections {
        target: Qt.application;
        function onStateChanged() {
			if (api.memory.has('main_backsound') && CONFIGS.getMainBacksound(api) == "false") return; 
            if (Qt.application.state === Qt.ApplicationActive) {
                if (!isPlaying) backMusic.play();
				player.play();
            } else {
                if (isPlaying) backMusic.pause();
				player.pause();
            }
        }
    }

    Audio {
		id: backMusic
        audioRole: Audio.MusicRole
        source: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == "海鸥沙滩"){return "../Resource/Background_package_999/海鸥沙滩/music.ogg";}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "赛博朋克"){return "../Resource/Background_package_999/赛博朋克/music.mp3";}
		else {return "../Resource/Background_package_999/海鸥沙滩/music.ogg";}
        autoPlay: true
        loops: Audio.Infinite
		volume: if(!api.memory.has(CONSTANTS.MAIN_COLOUR)){return 0.3;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "海鸥沙滩" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 0.3;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "赛博朋克" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 0.3;}
		else {return 0;}
    }
	
 
	
	Rectangle{
		
		id: descrip
		
		z:1
		// height:scaled(28)*20-vpx(20)
		color:'transparent'
			 anchors {
                top: settingbar.bottom;
				topMargin: scaled(720)*0.015+fullDesc.font.pixelSize+scaled(24)
                left: parent.left; 
				leftMargin: parent.width*.55
				rightMargin: parent.width*.1
                right: parent.right; 
                bottom: parent.bottom;
				// bottomMargin: 
				// if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 1){return vpx(15)}
					// else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 2){return vpx(3)}
					// else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 3){return vpx(0)}
					// else {return vpx(0)}
				bottomMargin: parent.height*.09+vpx(1)
            }
	    
	Flickable {
        id: flickable
        flickableDirection: Flickable.VerticalFlick
        anchors {
                top: parent.top;
                left: parent.left; 
                right: parent.right; 
                bottom: parent.bottom;
            }
		contentWidth: parent.width
		contentHeight: fullDesc.height
		clip: true
		boundsBehavior: Flickable.DragAndOvershootBounds
		visible: if((!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP)=="简介显示") && gamelist.count>0 ) {return 1;}
		else {return 0;}
		RetroText1{
			id: fullDesc
			text: allCollections[collectionIdx].games.get(gamelist.currentIndex).description
			width: flickable.width
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignJustify
		}
			
        /*Text {
            id: fullDesc
            color: "#eee"
            text: api.collections.get(collectionIdx).games.get(gamelist.currentIndex).description
            width: flickable.width
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignJustify
			style: Text.Outline;styleColor:"#555555"
			
			 font {
                pixelSize: if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 1){return scaled(35)*1.05}
					else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 2){return scaled(35)*0.9}
					else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 3){return scaled(35)*0.8}
					else {return scaled(35)}
				
                family: subtitleFont.name
				}
			
        }*/
      }
	  
	
	
	}
	
	MediaPlayer{
        id:player
        source: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '极致复古'){return '../Resource/Background_package_999/极致复古/bg.mp4'}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == '原神可莉'){return '../Resource/Background_package_999/原神可莉/bg.mp4'}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == '赛博朋克'){return '../Resource/Background_package_999/赛博朋克/bg.mp4'}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == '全息舞女'){return '../Resource/Background_package_999/全息舞女/bg.mp4'}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return '../Resource/Background_package_999/海鸥沙滩/bg.mp4'}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球'){return '../Resource/Background_package_999/流浪地球/bg.mp4'}
        loops: MediaPlayer.Infinite
        autoPlay: true
		volume: if(!api.memory.has(CONSTANTS.MAIN_COLOUR)){return 0;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "赛博朋克" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 1;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "原神可莉" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 1;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "流浪地球" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 1;}
		else if (api.memory.get(CONSTANTS.MAIN_COLOUR) == "全息舞女" && api.memory.get(CONSTANTS.MAIN_SOUND) == '主题音乐'){return 1;}
		else {return 0;}
                }
				
    VideoOutput {
        //anchors{fill: parent}
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        source: player
		visible: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩' ){return false;}
		else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '极致复古' ){return false;}
		else {return true}
        fillMode: VideoOutput.PreserveAspectCrop
		flushMode:VideoOutput.FirstFrame
    }

		Image {
				id: background
				visible: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return true;}
				else {return false}
				readonly property int bgCount: 14
				source: "../Resource/Background_package_999/海鸥沙滩/0.png"
				anchors.fill: parent
				fillMode: Image.PreserveAspectCrop
				smooth: false
			}

	
		Rectangle {
			id: settingbar
			width: parent.width
			height: vpx(40)
			color:'transparent'
			anchors {
			top: parent.top;
			left: parent.left;
			
		  }
		  
		ComboBox {
            id: itemColour
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainColour(api)
            model: CONSTANTS.AVAILABLE_COLOURS
            value: api.memory.get(CONSTANTS.MAIN_COLOUR) || ''
            onValueChange: updateColour()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false
			
			KeyNavigation.right: itemSound
			    Keys.onLeftPressed: {
					event.accepted = true;
					itemTextstyle.focus=true;
					forwardSound.play();
				}
	
				Keys.onRightPressed: {
				event.accepted = true;
				itemSound.focus = true
				forwardSound.play();
				}
			anchors {
				left: parent.left
				leftMargin: vpx(25)
				verticalCenter: parent.verticalCenter
			}

        }
		
		ComboBox {
            id: itemSound
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainSound(api)
            model: CONSTANTS.AVAILABLE_SOUNDS
            value: api.memory.get(CONSTANTS.MAIN_SOUND) || ''
            onValueChange: updateSound()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false
			KeyNavigation.right: itemBacksound
			Keys.onLeftPressed: {
					event.accepted = true;
					itemColour.focus=true;
					forwardSound.play();
				}
	
			Keys.onRightPressed: {
				event.accepted = true;
				itemBacksound.focus = true
				forwardSound.play();
				}
			anchors {
				left: itemColour.right
				leftMargin: itemColour.width*.6
				verticalCenter: parent.verticalCenter
			}
			

        }
		

	
		ComboBox {
            id: itemBacksound
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainBacksound(api)
            model: CONSTANTS.AVAILABLE_BACKSOUNDS
            value: api.memory.get(CONSTANTS.MAIN_BACKSOUND) || ''
            onValueChange: updateBacksound()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false
			KeyNavigation.right: itemTip
			Keys.onLeftPressed: {
					event.accepted = true;
					itemSound.focus=true;
					forwardSound.play();
				}
	
			Keys.onRightPressed: {
				event.accepted = true;
				itemTip.focus = true
				forwardSound.play();
				}
			anchors {
				left: itemSound.right
				leftMargin: itemColour.width*.6
				verticalCenter: parent.verticalCenter
			}


        }
		
		
		ComboBox {
            id: itemTip
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainTip(api)
            model: CONSTANTS.AVAILABLE_TIPS
            value: api.memory.get(CONSTANTS.MAIN_TIP) || ''
            onValueChange: updateTip()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false
			KeyNavigation.right: itemTextsize
			Keys.onLeftPressed: {
					event.accepted = true;
					itemBacksound.focus=true;
					forwardSound.play();
				}
	
			Keys.onRightPressed: {
				event.accepted = true;
				itemTextsize.focus = true
				forwardSound.play();
				}
			anchors {
				left: itemBacksound.right
				leftMargin: itemColour.width*.6
				verticalCenter: parent.verticalCenter
			}


        }
		
		ComboBox {
            id: itemTextsize
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainTextsize(api)
            model: CONSTANTS.AVAILABLE_TEXTSIZES
            value: api.memory.get(CONSTANTS.MAIN_TEXTSIZE) || ''
            onValueChange: updateTextsize()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false
			
			KeyNavigation.right: itemTextstyle
			anchors {
				left: itemTip.right
				leftMargin: itemColour.width*.6
				verticalCenter: parent.verticalCenter
			}
			Keys.onLeftPressed: {
					event.accepted = true;
					itemTip.focus=true;
					forwardSound.play();
				}
	
			Keys.onRightPressed: {
				event.accepted = true;
				itemTextstyle.focus = true
				forwardSound.play();
				}


        }

		ComboBox {
            id: itemTextstyle
			width: parent.width*.1
            fontSize: vpx(25)
            label: CONFIGS.getMainTextstyle(api)
            model: CONSTANTS.AVAILABLE_TEXTSTYLES
            value: api.memory.get(CONSTANTS.MAIN_TEXTSTYLE) || ''
            onValueChange: updateTextstyle()
			visible: itemColour.activeFocus|| itemSound.activeFocus ||itemTextsize.activeFocus ||itemTip.activeFocus || itemTextstyle.activeFocus || itemBacksound.activeFocus ? true : false

			KeyNavigation.right: itemColour
			Keys.onLeftPressed: {
					event.accepted = true;
					itemTextsize.focus=true;
					forwardSound.play();
				}
	
			Keys.onRightPressed: {
				event.accepted = true;
				itemColour.focus = true
				forwardSound.play();
				}
			anchors {
				left: itemTextsize.right
				leftMargin: itemColour.width*.6
				verticalCenter: parent.verticalCenter
			}


        }
		  
		  
	}
		
		Rectangle {
		id: footerbar
			width: parent.width
			height: vpx(50)*2
			color:'transparent'
			anchors {
			bottom: parent.bottom;
			left: parent.left;
			
		  }
		  	// RetroText5 {
				// id: pegasusLogo
				// text:'跳坑者联盟 PegasusG'
				// visible: api.memory.has(CONSTANTS.MAIN_TIP) && api.memory.get(CONSTANTS.MAIN_TIP) != '提示显示'
				// anchors{
				// bottom: if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return instruction.top;}
				// else {return parent.bottom}	
				// horizontalCenter: parent.horizontalCenter			
					// }
			// }

			Row {
				id:counttext
				
			spacing: vpx(20);
            height: vpx(20);
			
			anchors{
				horizontalCenter: parent.horizontalCenter
				bottom:parent.bottom
				bottomMargin: vpx(5)
			}	
			
			
			RetroText4 {
				id: count
				// width: parent.width*.5
				anchors.right : count2.left
				text:'游戏：'+zeroPad(currentGameIdx,collection.games.count.toString().length)+'/'+ collection.games.count+'  '+'合集：'+zeroPad(colidx,allCollections.length.toString().length)+'/'+allCollections.length
				horizontalAlignment: Text.AlignRight
				// anchors{
				// bottom: parent.bottom;
				// if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return instruction.top;}
				// else {return parent.bottom;}
				
				// bottomMargin: if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return vpx(4);}
				// else {return vpx(20);}
				// bottomMargin: vpx(5);
				
				// left: parent.left	
				// horizontalCenter: parent.horizontalCenter			
					// }
			}
			
			RetroText4 {
				id: count2
				width: parent.width*.5
				text:'  '+'手柄X设置/Y收藏'+'  '+'跳坑者联盟 G'
				horizontalAlignment: Text.AlignLeft
				// anchors{
				// bottom: parent.bottom;
				// if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return instruction.top;}
				// else {return parent.bottom;}
				
				// bottomMargin: if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return vpx(4);}
				// else {return vpx(20);}
				// bottomMargin: vpx(5);
				
				// left: parent.left	
				// horizontalCenter: parent.horizontalCenter			
					// }
			}
			}
			
			// RetroText3 {
				// id: instruction
				// text: "↑↓切换游戏，←→滚动简介，L1/R1切换类别，L2/R2翻页，手柄X设置，手柄Y收藏"
				// visible: false
				// if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示'){return true;}
				// else {return false}
				// anchors{
				// horizontalCenter: parent.horizontalCenter
				// bottom:parent.bottom
				
			   // }						
		    // }
			
			Row {
				
			spacing: vpx(20);
            height: vpx(20);
			visible:collection.games.count>0
			anchors{
				horizontalCenter: parent.horizontalCenter
				bottom:counttext.top
				bottomMargin: vpx(5)
			}	
			
			RetroText3 {
			id: timecount
			// width: parent.width*.5
			anchors.right : timecount2.left
             text:{
                   if (!allCollections[collectionIdx].games.get(gamelist.currentIndex))
                       return "-";
                   if (isNaN(allCollections[collectionIdx].games.get(gamelist.currentIndex).lastPlayed))
                       return "上次游玩:" + "从未玩过";

                   var now = new Date();

                   var diffHours = (now.getTime() - allCollections[collectionIdx].games.get(gamelist.currentIndex).lastPlayed.getTime()) / 1000 / 60 / 60;
                   if (diffHours < 24 && now.getDate() === allCollections[collectionIdx].games.get(gamelist.currentIndex).lastPlayed.getDate())
                       return "上次游玩:" + "今天玩过";

                   var diffDays = Math.round(diffHours / 24);
                   if (diffDays <= 1)
                       return "上次游玩:" + "昨天玩过";

                   return "上次游玩:" + diffDays + "天以前"
					  }
					
					// anchors{
						// horizontalCenter: count.horizontalCenter
						// bottom:count.top
						// bottomMargin: vpx(4)
					   // }	

					// visible:  if((!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示') || collection.games.count == 0){return false;}
					// else {return true}
					// opacity: 1
				}
				
			RetroText3 {
			id: timecount2
			width: parent.width*.5
			horizontalAlignment: Text.AlignLeft
					text: {if (!allCollections[collectionIdx].games.get(gamelist.currentIndex))
								   return '  '+"-";

							   var minutes = Math.ceil(allCollections[collectionIdx].games.get(gamelist.currentIndex).playTime / 60)
							   if (minutes <= 90)
								   return '  '+"游戏时长:" + Math.round(minutes) + "分钟";

							   return '  '+"游戏时长:" + parseFloat((minutes / 60).toFixed(1)) + "小时"
					}
					
					// anchors{
						// left: timecount.right
						// bottom:count.top
						// bottomMargin: vpx(4)
					   // }	

					// visible:  if((!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP) == '提示显示') || collection.games.count == 0){return false;}
					// else {return true}
					// opacity: 1
				}
		
				// Text {
					// id: timecount2
					// text: {if (!currentGame)
								   // return "-";

							   // var minutes = Math.ceil(currentGame.playTime / 60)
							   // if (minutes <= 90)
								   // return "游戏时长:" + Math.round(minutes) + "分钟";

							   // return "游戏时长:" + parseFloat((minutes / 60).toFixed(1)) + "小时"
					// }
					// color: currentView == 'collectionList' ? "#fff" : shadeColor2;
					// anchors.verticalCenter: parent.verticalCenter;
					// font {
						// pixelSize: Math.min(parent.width * .04,parent.height * .3)
						// family: subtitleFont.name
					// }

					// visible: (currentView != 'gameList' || (currentGameList.count == 0 && showSorting)) ? false : true;
					// opacity: .5
				// }
			}
		
		}
		
	
    Rectangle {
		id: maincol
        width: parent.width
		color: 'transparent'
        // height: scaled(720)
		anchors.top: settingbar.bottom;
		anchors.bottom: footerbar.top;
		anchors.horizontalCenter: parent.horizontalCenter
        // anchors.centerIn: settingbar

        readonly property int textHeight: collName.height
		

        RetroText {
            id: collName
            anchors.top: parent.top
			anchors.topMargin: parent.height*0.015
			anchors.left: parent.left
            anchors.leftMargin: if(!api.memory.has(CONSTANTS.MAIN_TIP)){return parent.width*.05+vpx(180);}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介显示'){return parent.width*.05+vpx(180);}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '原神可莉'){return parent.width*.05+vpx(180);}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '赛博朋克'){return parent.width*.05+vpx(180);}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '全息舞女'){return parent.width*.05+vpx(180);}		
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球'){return parent.width*.05+vpx(180);}				
			else {return parent.width*.3+vpx(180)}
            // anchors.leftMargin: parent.width*.05+vpx(180)
            // anchors.horizontalCenter: parent.horizontalCenter
            text: collection.name
		
        }
		
		RetroText {
            id: desName
            anchors.top: parent.top
			anchors.topMargin: parent.height*0.015
            anchors.left: parent.left; 
			anchors.leftMargin: parent.width*.6+scaled(110)
            // anchors.rightMargin: scaled(250)
            // anchors.horizontalCenter: flickable.horizontalCenter
            text: '简介'
			visible: if(!api.memory.has(CONSTANTS.MAIN_TIP) || api.memory.get(CONSTANTS.MAIN_TIP)=="简介显示" ) {return 1;}
			else {return 0;}
		
        }
		
		



        ListView {
            id: gamelist
		
            property int maxVisibleLines: if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE)){return 15 + (CONFIGS.getMainTextsize(api)-2)*5}
			else {return 15;}
            // readonly property int maxVisibleLines: 15
            readonly property int leftPadding: scaled(64)
            readonly property int digitCount: collection.games.count.toString().length
			width: parent.width*.44
            height: (parent.textHeight)* maxVisibleLines-vpx(1)
            anchors.top: collName.bottom
            anchors.topMargin: scaled(24)
            anchors.left: parent.left
            anchors.leftMargin:  if(!api.memory.has(CONSTANTS.MAIN_TIP)){return parent.width*.05;}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介显示'){return parent.width*.05;}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '原神可莉'){return parent.width*.05;}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '赛博朋克'){return parent.width*.05;}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '全息舞女'){return parent.width*.05;}
			else if( api.memory.get(CONSTANTS.MAIN_TIP) == '简介关闭' && api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球'){return parent.width*.05;}
			else {return parent.width*.3}
            // anchors.leftMargin: parent.width*.05
            anchors.right: flickable.left
			// anchors.bottom:parent.bottom
            // anchors.rightMargin: scaled(100)
            clip: true
			
            focus: true
            keyNavigationWraps: true

            Keys.onPressed: {
                // if (event.isAutoRepeat)
                    // return;
				if (api.keys.isUp(event)) {
                    event.accepted = true;
					currentIndex = Math.max(0,currentIndex -1);
					forwardSound.play()
                    return;
                }
				if (api.keys.isDown(event)) {
                    event.accepted = true;
					currentIndex = Math.min(collection.games.count  - 1,
                                            currentIndex + 1);
					forwardSound.play()
                    return;
                }
                if (api.keys.isPageDown(event)) {
                    event.accepted = true;
					currentIndex = Math.min(collection.games.count  - 1,
                                            currentIndex + maxVisibleLines);
					nextSound.play()
                    return;
                }
                if (api.keys.isPageUp(event)) {
                    event.accepted = true;
                    currentIndex = Math.max(0, currentIndex - maxVisibleLines);
					nextSound.play()
                    return;
					}
				if (api.keys.isNextPage(event)) {
                    event.accepted = true;
					nextCollection()
					nextSound.play()
					
					// currentIndex = Math.min(collection.games.count  - 1,
                                            // currentIndex + maxVisibleLines);
                    return;
                }
                if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
					prevCollection()
					nextSound.play()
                    // currentIndex = Math.max(0, currentIndex - maxVisibleLines);
                    return;
                }
				
            }

            model: allCollections[collectionIdx].games
            delegate: RetroText2 {
                id: gametitle
				// lineHeight: 1.15
                readonly property int myIndex: index
                text: zeroPad(index + 1, gamelist.digitCount) + "." + modelData.title
                leftPadding: gamelist.leftPadding+scaled(20)
                width: ListView.view.width
                elide: Text.ElideRight

                Keys.onPressed: {
                    if (event.isAutoRepeat)
                        return;

                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        launchGame(modelData);
                        return;
                    }
                }
				
					Image {
							visible: favorite && collectionIdx != 2 //&& onlyFavorite === false;
							source: "heart.png"
							sourceSize { width: 256; height: 256 }
							verticalAlignment: Image.AlignVCenter;
							height: parent.height*.8;
							width:	height


							anchors {
								verticalCenter: parent.verticalCenter;
								left: parent.left;
								leftMargin: scaled(55);
							}
							opacity: 1
							}

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (gamelist.currentIndex !== parent.myIndex) {
                            gamelist.currentIndex = parent.myIndex;
                            return;
                        }
                        launchGame(modelData);
                    }
                }
            }
			



            highlight: Item {
				id: gifIcon
				
					Connections {
						target: Qt.application;
						function onStateChanged() {
							// if (api.memory.get(CONSTANTS.MAIN_SOUND) == '全部静音') {
								// console.log('playBGM was false')
								// return;
							// }
							if (Qt.application.state === Qt.ApplicationActive) {
								gifImage.playing = true;
								gifImage1.playing = true;
								gifImage2.playing = true;
								gifImage3.playing = true;
								gifImage4.playing = true;
							} else {
								gifImage.playing = false;
								gifImage1.playing = false;
								gifImage2.playing = false;
								gifImage3.playing = false;
								gifImage4.playing = false;
							}
						}
					}
				
				AnimatedImage {
                    id: gifImage
                    anchors{top: parent.top; topMargin: -scaled(5); left: parent.left; leftMargin: scaled(20)}
                    source:"../Resource/Background_package_999/赛博朋克/mouse.gif"
					// mipmap: true
                    height: scaled(40);
					width: scaled(40);  
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '赛博朋克'){return true;}
					else {return false}
				  
					
				  }
				  
				AnimatedImage {
                    id: gifImage1
                    anchors{top: parent.top; topMargin: -scaled(0); left: parent.left; leftMargin: scaled(20)}
                    source:"../Resource/Background_package_999/全息舞女/mouse.gif"
					// mipmap: true
                    height: scaled(30);
					width: scaled(20);  
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '全息舞女'){return true;}
					else {return false}
				  }
				  
				AnimatedImage {
                    id: gifImage2
                    anchors{top: parent.top; topMargin: -scaled(0); left: parent.left; leftMargin: scaled(20)}
                    source:"../Resource/Background_package_999/原神可莉/mouse.gif"
					// mipmap: true
                    height: scaled(30);
					width: scaled(30);  
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '原神可莉'){return true;}
					else {return false}
				  }
				  
				AnimatedImage {
                    id: gifImage3
                    anchors{top: parent.top; topMargin: 0; left: parent.left; leftMargin: scaled(20)}
                    source:"../Resource/Background_package_999/极致复古/mouse.gif"
					// mipmap: true
                    height: scaled(30);
					width: scaled(30);  
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '极致复古'){return true;}
					else {return false}
				  }
			          
                AnimatedSprite {
					id: gifImage4
                    source: "../Resource/Background_package_999/海鸥沙滩/mouse.png"
                    frameWidth: 16
                    frameHeight: 6
                    frameCount: 4
                    frameDuration: 150
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return true;}
					else {return false}
				  
                    interpolate: false
                    smooth: false

                    height: scaled(20)
                    width: height / frameHeight * frameWidth
                }

				AnimatedImage {
                    id: gifImage5
                    anchors{top: parent.top; topMargin:-vpx(3); left: parent.left; leftMargin: scaled(7)}
                    source:"../Resource/Background_package_999/流浪地球/mouse.gif"
					// mipmap: true
                    height: scaled(30);
					width: scaled(50);  
					visible: if(!gamelist.focus ){return false;}
					else if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球'){return true;}
					else {return false}
				  }
				
            }
            highlightMoveDuration: 0

        onCurrentIndexChanged: {
                const page = Math.floor(currentIndex / (maxVisibleLines));
                contentY = page * maxVisibleLines * parent.textHeight;

                const bg_idx = page % background.bgCount;
				if(collection.games.count==0 && api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return background.source = "../Resource/Background_package_999/海鸥沙滩/0.png"}
				else if(api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return background.source = "../Resource/Background_package_999/海鸥沙滩/%1.png".arg(bg_idx);}
				// background.source = "../Resource/Background_package_999/海鸥沙滩/0.png"
				// else return 
                bgFire.visible = bg_idx == 9;
            }
        }

        // MouseArea {
            // anchors.top: parent.top
            // anchors.left: parent.left
            // anchors.right: gamelist.left
            // anchors.bottom: parent.bottom
            // onClicked: prevCollection()
        // }
        // MouseArea {
            // anchors.top: parent.top
            // anchors.left: gamelist.right
            // anchors.right: parent.right
            // anchors.bottom: parent.bottom
            // onClicked: nextCollection()
        // }

        Birds {
			id: bgBird
			visible: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return true;}
					else {return false}
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: scaled(440)
        }

        Fire {
            id: bgFire
            visible: if(!api.memory.has(CONSTANTS.MAIN_COLOUR) || api.memory.get(CONSTANTS.MAIN_COLOUR) == '海鸥沙滩'){return true;}
					else {return false}
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: scaled(520)
            anchors.topMargin: scaled(597)
        }
    }
}
