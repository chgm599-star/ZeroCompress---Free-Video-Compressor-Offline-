
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart' as vc;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProApp()));

class ProApp extends StatefulWidget { @override State<ProApp> createState()=>_ProAppState(); }
class _ProAppState extends State<ProApp> {
  String? path; int? orig; String log="Original Professional Fast\n2GB Support 100% Private";
  bool busy=false; String quality="Visually Lossless"; String? out;
  Future pick() async {
    await [Permission.storage, Permission.videos, Permission.manageExternalStorage].request();
    var r = await FilePicker.platform.pickFiles(type: FileType.video);
    if(r!=null){ setState((){ path=r.files.single.path; orig=r.files.single.size; log="Selected: ${r.files.single.name}\n${(orig!/1024/1024).toStringAsFixed(1)} MB Ready"; }); }
  }
  Future compress() async {
    if(path==null) return;
    setState(()=>busy=true);
    try{
      setState(()=>log="FAST HARDWARE ENCODING...\n${quality}\nPhone chip 3x tez");
      var info = await vc.VideoCompress.compressVideo(path!, quality: quality=="Visually Lossless" ? vc.VideoQuality.Res1920x1080Quality : quality=="High Quality" ? vc.VideoQuality.Res1280x720Quality : vc.VideoQuality.Res640x480Quality, deleteOrigin:false, includeAudio:true);
      if(info?.path!=null){
        var f=File(info!.path!); var dir=Directory("/storage/emulated/0/Download"); if(!await dir.exists()) dir = await getExternalStorageDirectory() as Directory;
        var newPath="${dir.path}/ZC_PRO_${DateTime.now().millisecondsSinceEpoch}.mp4"; await f.copy(newPath);
        var ns=await File(newPath).length();
        setState(()=>log="DONE PRO! Original: ${(orig!/1024/1024).toStringAsFixed(1)} MB Compressed: ${(ns/1024/1024).toStringAsFixed(1)} MB Saved: ${(100-ns/orig!*100).toStringAsFixed(0)}% Saved: Download");
        setState(()=>out=newPath);
      }
    }catch(e){
      setState(()=>log="Fallback FFmpeg... $e");
      var dl=Directory("/storage/emulated/0/Download"); var op="${dl.path}/ZC_FFMPEG_${DateTime.now().millisecondsSinceEpoch}.mp4";
      var crf = quality=="Visually Lossless" ? "18" : quality=="High Quality" ? "23" : "28";
      var cmd="-i '$path' -vcodec libx264 -crf $crf -preset ultrafast -acodec aac -b:a 128k '$op'";
      await FFmpegKit.executeAsync(cmd, (s) async { var rc=await s.getReturnCode(); if(rc!=null && rc.isValueSuccess()){ setState(()=>out=op); setState(()=>log="DONE! Saved to Download"); } });
    } finally{ setState(()=>busy=false); }
  }
  @override Widget build(BuildContext c){
    return Scaffold(backgroundColor: Color(0xFF070A07), body: SafeArea(child: Padding(padding: EdgeInsets.all(16), child: Column(children:[
      Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:Color(0xFF00FF88),shape:BoxShape.circle),child:Center(child:Text("ZC",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold)))), SizedBox(width:10), Column(crossAxisAlignment:CrossAxisAlignment.start,children:[RichText(text:TextSpan(children:[TextSpan(text:"Zero",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)), TextSpan(text:"Compress",style:TextStyle(color:Color(0xFF00FF88),fontWeight:FontWeight.bold,fontSize:16))])), Text("100% PRIVATE BROWSER ONLY",style:TextStyle(color:Colors.white54,fontSize:8))])]),
      SizedBox(height:16),
      Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Color(0xFF00FF88).withOpacity(0.1),borderRadius:BorderRadius.circular(20),border:Border.all(color:Color(0xFF00FF88).withOpacity(0.3))),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.bolt,color:Color(0xFF00FF88),size:14),SizedBox(width:6),Text("Using H.265 Visually Lossless Engine",style:TextStyle(color:Color(0xFF00FF88),fontSize:11))])),
      SizedBox(height:18),
      Text("Compress video to",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Colors.white)), Text("zero cost.",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Color(0xFF00FF88))), Text("Zero upload.",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Colors.white)),
      SizedBox(height:12),
      Container(padding:EdgeInsets.all(16),decoration:BoxDecoration(color:Color(0xFF121612),borderRadius:BorderRadius.circular(16),border:Border.all(color:Colors.white10)),child:Column(children:[
        if(path==null) Column(children:[Icon(Icons.video_file,size:40,color:Colors.white24),SizedBox(height:8),Text("Drop video or click to select",style:TextStyle(color:Colors.white38)),SizedBox(height:12),ElevatedButton(onPressed:pick,style:ElevatedButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Colors.black),child:Text("Select Video (2GB)"))])
        else Column(children:[
          Row(children:[Icon(Icons.videocam,color:Color(0xFF00FF88)),SizedBox(width:8),Expanded(child:Text(path!.split("/").last,style:TextStyle(color:Colors.white,fontSize:12),overflow:TextOverflow.ellipsis)), Container(padding:EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.white10,borderRadius:BorderRadius.circular(6)),child:Text("${(orig!/1024/1024).toStringAsFixed(1)} MB",style:TextStyle(color:Colors.white70,fontSize:10))) ]),
          SizedBox(height:14), Text("QUALITY MODE",style:TextStyle(color:Colors.white38,fontSize:10,letterSpacing:1)), SizedBox(height:8),
          Row(children:[ for(var q in ["Visually Lossless","High Quality","Max Compression"]) Expanded(child: GestureDetector(onTap:()=>setState(()=>quality=q), child: Container(margin:EdgeInsets.symmetric(horizontal:4),padding:EdgeInsets.all(10),decoration:BoxDecoration(color: quality==q ? Color(0xFF00FF88).withOpacity(0.15) : Colors.white.withOpacity(0.05),borderRadius:BorderRadius.circular(10),border:Border.all(color: quality==q ? Color(0xFF00FF88) : Colors.white10)),child:Column(children:[Text(q,style:TextStyle(color: quality==q?Color(0xFF00FF88):Colors.white70,fontSize:9,fontWeight:FontWeight.bold),textAlign:TextAlign.center), SizedBox(height:4), Text(q=="Visually Lossless"?"CRF 18":q=="High Quality"?"CRF 23":"CRF 28",style:TextStyle(color:Colors.white38,fontSize:8))])))), ]),
          SizedBox(height:14), SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:busy?null:compress,icon:Icon(Icons.bolt),label:Text(busy?"Compressing...":"Compress Video - $quality"),style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF00FF88),foregroundColor:Colors.black,padding:EdgeInsets.symmetric(vertical:14)))),
        ]),
      ])),
      SizedBox(height:14), if(busy) LinearProgressIndicator(color:Color(0xFF00FF88),backgroundColor:Colors.white10), SizedBox(height:8),
      Expanded(child: Container(width:double.infinity,padding:EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.black,borderRadius:BorderRadius.circular(12)),child:SingleChildScrollView(child:Text(log,style:TextStyle(color:Colors.white70,fontSize:12))))),
    ]))));
  }
}
