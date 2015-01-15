:- use_module(library(process)).
:- use_module(library(unix)).
%:- use_module(library(memfile)).
:- consult(analizilo2).

%%% revo_xml('http://retavortaro.de/revo/xml').
revo_xml('/home/revo/revo/xml').
txt_xsl('/home/revo/voko/xsl/revotxt_eo.xsl').
skribo_pado('kontrolitaj').
xslt('/usr/bin/xsltproc').
lynx('/usr/bin/lynx').

/***
revo_art_txt(XmlInput,Txt) :-
% xsltproc $VOKO/xsl/revotxt_eo.xsl $infile
  xslt(Xslt), txt_xsl(Xsl),
  process_create(Xslt,[Xsl,XmlInput],[stdout(pipe(HtmlOut))]),
  read_stream_to_codes(HtmlOut,Html),
  close(HtmlOut),
  
% lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin 
  lynx(Lynx),
  process_create(Lynx,['-nolist','-dump','-assume_local_charset=utf8','-display_charset=utf8','-stdin'],
		 [stdin(pipe(HtmlIn)),stdout(pipe(TxtOut))]),
  format(HtmlIn,'~s',[Html]),
  close(HtmlIn),
%%%  pipe(HtmlOut,HtmlIn),
%%% close(HtmlOut), close(HtmlIn),
  read_stream_to_codes(TxtOut,Txt),
  close(TxtOut).
***/

revo_art_txt(XmlInput,Txt) :-
% xsltproc $VOKO/xsl/revotxt_eo.xsl $infile
  xslt(XsltProc), txt_xsl(Xsl),
% lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin 
  lynx(Lynx),
  atomic_list_concat([XsltProc,Xsl,XmlInput,'|',Lynx,'-nolist','-dump',
		      '-assume_local_charset=utf8','-display_charset=utf8','-stdin'],' ',Cmd),
  open(pipe(Cmd),read,HtmlOut,[]),
  read_stream_to_codes(HtmlOut,Txt),
  close(HtmlOut).

analizu_revo_art(Art) :-
  revo_xml(XmlPado),
  atomic_list_concat([XmlPado,'/',Art,'.xml'],XmlInput),
  revo_art_txt(XmlInput,Txt),
  analizu_tekston_kopie(Txt).

analizu_revo_art_litero(Litero) :-
   revo_xml(XmlPado), skribo_pado(Kontrolitaj),
   atomic_list_concat([XmlPado,'/',Litero,'*.xml'],XmlInput),
   expand_file_name(XmlInput,XmlFiles),
   forall(member(XmlFile,XmlFiles),
     (
       atom_concat(XmlPado,File,XmlFile),
       atom_concat(Art,'.xml',File),
       sub_atom(Art,0,2,_,Unua), % ekz.'/a'
       atomic_list_concat([Kontrolitaj,Unua,Art,'.html'],HtmlFile),
       format('~w -> ~w~n',[XmlFile,HtmlFile]),
       revo_art_txt(XmlFile,Txt),
       analizu_tekston_kopie(Txt,HtmlFile)
     )
   ).

