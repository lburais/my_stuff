FasdUAS 1.101.10   ��   ��    k             l     ��  ��    4 .----------------------------------------------     � 	 	 \ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   
  
 l     ��  ��    - ' Settings Start: Change these as needed     �   N   S e t t i n g s   S t a r t :   C h a n g e   t h e s e   a s   n e e d e d      p         ������ 0 apptitle  ��        l     ����  r         m        �   B E x p o r t   A l b u m s   a n d   F o l d e r s   t o   D i s k  o      ���� 0 apptitle  ��  ��        l     ��������  ��  ��        p         ������ 0 gdest gDest��        l   	  ����   r    	 ! " ! c     # $ # m    ��
�� boovfals $ m    ��
�� 
bool " o      ���� "0 allowusertodest allowUserToDest��  ��     % & % l  
  ' ( ) ' r   
  * + * c   
  , - , c   
  . / . m   
  0 0 � 1 1  / V o l u m e s / p h o t o / m    ��
�� 
psxf - m    ��
�� 
ctxt + o      ���� 0 gdest gDest ( 0 * the destination folder (use a valid path)    ) � 2 2 T   t h e   d e s t i n a t i o n   f o l d e r   ( u s e   a   v a l i d   p a t h ) &  3 4 3 l     ��������  ��  ��   4  5 6 5 p       7 7 ������ 0 gsmartalbum gSmartAlbum��   6  8 9 8 l    :���� : r     ; < ; m     = = � > >  P h o t o s   i n < o      ���� 0 gsmartalbum gSmartAlbum��  ��   9  ? @ ? l     ��������  ��  ��   @  A B A p       C C ������ 0 	gnoaction 	gNoAction��   B  D E D l    F���� F r     G H G c     I J I m    ��
�� boovfals J m    ��
�� 
bool H o      ���� 0 	gnoaction 	gNoAction��  ��   E  K L K l     ��������  ��  ��   L  M N M l   ! O���� O r    ! P Q P c     R S R m    ��
�� boovfals S m    ��
�� 
bool Q o      ���� 20 allowusertoselectalbums allowUserToSelectAlbums��  ��   N  T U T l     ��������  ��  ��   U  V W V l     �� X Y��   X   Settings End    Y � Z Z    S e t t i n g s   E n d W  [ \ [ l     �� ] ^��   ] 4 .----------------------------------------------    ^ � _ _ \ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \  ` a ` l     ��������  ��  ��   a  b c b l     �� d e��   d 4 .----------------------------------------------    e � f f \ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - c  g h g l     �� i j��   i   my Functions Start    j � k k &   m y   F u n c t i o n s   S t a r t h  l m l l     ��������  ��  ��   m  n o n i      p q p I      �� r���� .0 mypathtoalbumorfolder MyPathToAlbumOrFolder r  s�� s o      ���� 0 targetobject targetObject��  ��   q k     � t t  u v u l     �� w x��   w   retrive full path    x � y y $   r e t r i v e   f u l l   p a t h v  z { z r      | } | o     ���� 0 targetobject targetObject } o      ���� 0 	theobject 	theObject {  ~  ~ r    	 � � � n     � � � 1    ��
�� 
pnam � o    ���� 0 targetobject targetObject � o      ���� 0 thepath thePath   ��� � O   
 � � � � T    � � � Q    � � � � � Z    o � � ��� � =    � � � n     � � � m    ��
�� 
pcls � n     � � � 1    ��
�� 
pare � o    ���� 0 	theobject 	theObject � m    ��
�� 
IPfd � k     ? � �  � � � r     ' � � � l    % ����� � n     % � � � 1   # %��
�� 
pnam � n     # � � � 1   ! #��
�� 
pare � o     !���� 0 	theobject 	theObject��  ��   � o      ���� 0 
foldername 
folderName �  � � � r   ( / � � � b   ( - � � � b   ( + � � � o   ( )���� 0 
foldername 
folderName � m   ) * � � � � �  : � o   + ,���� 0 thepath thePath � o      ���� 0 thepath thePath �  � � � r   0 7 � � � n   0 5 � � � 1   3 5��
�� 
ID   � n   0 3 � � � 1   1 3��
�� 
pare � o   0 1���� 0 	theobject 	theObject � o      ���� 0 thisid thisID �  ��� � r   8 ? � � � 5   8 =�� ���
�� 
IPfd � o   : ;���� 0 thisid thisID
�� kfrmID   � o      ���� 0 	theobject 	theObject��   �  � � � =  B I � � � n   B G � � � m   E G��
�� 
pcls � n   B E � � � 1   C E��
�� 
pare � o   B C���� 0 	theobject 	theObject � m   G H��
�� 
IPal �  ��� � k   L k � �  � � � r   L S � � � l  L Q ����� � n   L Q � � � 1   O Q��
�� 
pnam � n   L O � � � 1   M O��
�� 
pare � o   L M���� 0 	theobject 	theObject��  ��   � o      ���� 0 	albumname 	albumName �  � � � r   T [ � � � b   T Y � � � b   T W � � � o   T U���� 0 	albumname 	albumName � m   U V � � � � �  : � o   W X���� 0 thepath thePath � o      ���� 0 thepath thePath �  � � � r   \ c � � � n   \ a � � � 1   _ a��
�� 
ID   � n   \ _ � � � 1   ] _��
�� 
pare � o   \ ]���� 0 	theobject 	theObject � o      ���� 0 thisid thisID �  ��� � r   d k � � � 5   d i�� ���
�� 
IPal � o   f g���� 0 thisid thisID
�� kfrmID   � o      ���� 0 	theobject 	theObject��  ��  ��   � R      ������
�� .ascrerr ****      � ****��  ��   � k   w � � �  � � � r   w ~ � � � b   w | � � � b   w z � � � o   w x���� 0 gdest gDest � m   x y � � � � �  : � o   z {���� 0 thepath thePath � o      ���� 0 thepath thePath �  ��� � L    � � � o    ����� 0 thepath thePath��   � m   
  � �l                                                                                  Phts  alis      Ra                             BD ����
Photos.app                                                     ����            ����  
 cu             Applications  /:Applications:Photos.app/   
 P h o t o s . a p p    R a  Applications/Photos.app   / ��  ��   o  � � � l     ��������  ��  ��   �  � � � i     � � � I      � ��~� 0 	mylogthis 	MyLogThis �  ��} � o      �|�| 0 thetext theText�}  �~   � k     6 � �  � � � l     � � � � I    �{ ��z
�{ .ascrcmnt****      � **** � o     �y�y 0 thetext theText�z   �  
to console    � � � �  t o   c o n s o l e �  � � � Z    � ��x�w � H    
 � � l   	 �v�u  C    	 o    �t�t 0 thetext theText m     �  #�v  �u   � I   �s
�s .sysonotfnull��� ��� TEXT o    �r�r 0 thetext theText �q�p
�q 
appr o    �o�o 0 apptitle  �p  �x  �w   � 	 r    $

 b    " l    �n�m I    �l
�l .earsffdralis        afdr m    �k
�k afdrdown �j�i
�j 
rtyp m    �h
�h 
ctxt�i  �n  �m   m     ! � 2 e x p o r t a l b u m s t o f o l d e r s . t x t o      �g�g 0 thefile theFile	 �f I  % 6�e�d
�e .sysoexecTEXT���     TEXT b   % 2 b   % , b   % * m   % & � 
 e c h o   n   & ) 1   ' )�c
�c 
strq o   & '�b�b 0 thetext theText m   * +   �!!    > >   n   , 1"#" 1   / 1�a
�a 
strq# l  , /$�`�_$ n   , /%&% 1   - /�^
�^ 
psxp& o   , -�]�] 0 thefile theFile�`  �_  �d  �f   � '(' l     �\�[�Z�\  �[  �Z  ( )*) l     �Y+,�Y  +   my Functions End   , �-- "   m y   F u n c t i o n s   E n d* ./. l     �X01�X  0 4 .----------------------------------------------   1 �22 \ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -/ 343 l     �W�V�U�W  �V  �U  4 565 l  "g7�T�S7 O   "g898 k   &f:: ;<; l  & &�R�Q�P�R  �Q  �P  < =>= t   & .?@? l  ( -ABCA I  ( -�O�N�M
�O .miscactvnull��� ��� null�N  �M  B   give 2 minutes ...   C �DD &   g i v e   2   m i n u t e s   . . .@ m   & '�L�L`> EFE l  / /�K�J�I�K  �J  �I  F GHG n  / ?IJI I   0 ?�HK�G�H 0 	mylogthis 	MyLogThisK L�FL c   0 ;MNM b   0 7OPO m   0 1QQ �RR  # S t a r t :  P l  1 6S�E�DS I  1 6�C�B�A
�C .misccurdldt    ��� null�B  �A  �E  �D  N m   7 :�@
�@ 
TEXT�F  �G  J  f   / 0H TUT n  @ JVWV I   A J�?X�>�? 0 	mylogthis 	MyLogThisX Y�=Y b   A FZ[Z m   A D\\ �]]  # N o A c t i o n :  [ o   D E�<�< 0 	gnoaction 	gNoAction�=  �>  W  f   @ AU ^_^ r   K P`a` m   K L�;�;  a o      �:�: 0 nbphotos nbPhotos_ bcb l  Q Q�9�8�7�9  �8  �7  c ded l  Q Q�6fg�6  f B < select the destination folder  --> theDestinationRootFolder   g �hh x   s e l e c t   t h e   d e s t i n a t i o n   f o l d e r     - - >   t h e D e s t i n a t i o n R o o t F o l d e re iji Z   Q �kl�5�4k o   Q R�3�3 "0 allowusertodest allowUserToDestl k   U �mm non r   U npqp I  U j�2�1r
�2 .sysostflalis    ��� null�1  r �0st
�0 
prmps m   Y \uu �vv b S e l e c t   a   d e s t i n a t i o n   f o l d e r   t o   s a v e   t h e   a l b u m s   t ot �/w�.
�/ 
dflcw l  _ dx�-�,x c   _ dyzy o   _ `�+�+ 0 gdest gDestz m   ` c�*
�* 
alis�-  �,  �.  q 1      �)
�) 
rslto {|{ r   o ~}~} c   o |� c   o z��� l  o x��(�'� c   o x��� l  o v��&�%� l  o v��$�#� n   o v��� 1   r v�"
�" 
psxp� 1   o r�!
�! 
rslt�$  �#  �&  �%  � m   v w� 
�  
ctxt�(  �'  � m   x y�
� 
psxf� m   z {�
� 
ctxt~ o      �� 0 gdest gDest| ��� r    ���� b    ���� o    ��� 0 gdest gDest� m   � ��� ��� 6 : e x p o r t a l b u m s t o f o l d e r s . c o n f� o      �� 0 conffile confFile�  �5  �4  j ��� n  � ���� I   � ����� 0 	mylogthis 	MyLogThis� ��� b   � ���� m   � ��� ��� * # D e s t i n a t i o n   f o l d e r :  � o   � ��� 0 gdest gDest�  �  �  f   � �� ��� l  � �����  �  �  � ��� l  � �����  � , & Display a dialog to select the albums   � ��� L   D i s p l a y   a   d i a l o g   t o   s e l e c t   t h e   a l b u m s� ��� r   � ���� n   � ���� 1   � ��
� 
pnam� 2  � ��
� 
IPal� o      �� 0 allalbumnames allAlbumNames� ��� Z   � ������ o   � ��� 20 allowusertoselectalbums allowUserToSelectAlbums� r   � ���� I  � ����
� .gtqpchltns    @   @ ns  � o   � ��� 0 allalbumnames allAlbumNames� �
��
�
 
prmp� m   � ��� ��� $ S e l e c t   s o m e   a l b u m s� �	��
�	 
mlsl� m   � ��
� boovtrue�  � o      �� 0 
albumnames 
albumNames�  � r   � ���� o   � ��� 0 allalbumnames allAlbumNames� o      �� 0 
albumnames 
albumNames� ��� l  � �����  �  �  � ��� l  � �� ���   � @ : Display a dialog to select update or replace --> fReplace   � ��� t   D i s p l a y   a   d i a l o g   t o   s e l e c t   u p d a t e   o r   r e p l a c e   - - >   f R e p l a c e� ��� r   � ���� I  � �����
�� .sysodlogaskr        TEXT� m   � ��� ��� P D o   y o u   w a n t   t o   u p d a t e   o r   r e p l a c e   i m a g e s ?� ����
�� 
btns� J   � ��� ��� m   � ��� ���  R e p l a c e� ���� m   � ��� ���  U p d a t e��  � ����
�� 
dflt� m   � ����� � ����
�� 
disp� m   � ����� � ����
�� 
givu� m   � ����� 
� �����
�� 
appr� o   � ����� 0 apptitle  ��  � 1      ��
�� 
rslt� ��� r   ���� l  ������� =  ���� n   � ���� 1   � ���
�� 
bhit� 1   � ���
�� 
rslt� m   ��� ���  R e p l a c e��  ��  � o      ���� 0 freplace fReplace� ��� n ��� I  ������� 0 	mylogthis 	MyLogThis� ���� c  ��� b  ��� m  �� ���  # R e p l a c e :  � o  ���� 0 freplace fReplace� m  ��
�� 
ctxt��  ��  �  f  � ��� l ��������  ��  ��  � ��� Z  G������� > ��� o  ���� 0 
albumnames 
albumNames� m  ��
�� boovfals� l C���� k  C�� ��� l ��������  ��  ��  � ��� r  #� � m  ����    o      ���� 0 cnt  �  l $$��������  ��  ��    n $: I  %:������ 0 	mylogthis 	MyLogThis �� b  %6	
	 b  %2 m  %( �  P r o c e s s i n g   l (1���� c  (1 l (/���� n  (/ 1  +/��
�� 
leng o  (+���� 0 
albumnames 
albumNames��  ��   m  /0��
�� 
ctxt��  ��  
 m  25 �    a l b u m s��  ��    f  $%  l ;;��������  ��  ��   �� X  ;C�� k  S>  l SS��������  ��  ��     r  S\!"! [  SX#$# o  SV���� 0 cnt  $ m  VW���� " o      ���� 0 cnt    %&% r  ]f'(' n  ]b)*) 1  ^b��
�� 
pnam* o  ]^���� 0 onealbum oneAlbum( o      ���� 0 	albumname 	albumName& +,+ l gg��������  ��  ��  , -��- Z  g>./��0. H  go11 l gn2����2 E  gn343 o  gj���� 0 
albumnames 
albumNames4 o  jm���� 0 	albumname 	albumName��  ��  / k  r�55 676 l rr��������  ��  ��  7 898 n r�:;: I  s���<���� 0 	mylogthis 	MyLogThis< =��= b  s~>?> b  sz@A@ m  svBB �CC  # A l b u m  A o  vy���� 0 	albumname 	albumName? m  z}DD �EE    n o t   s e l e c t e d��  ��  ;  f  rs9 F��F l ����������  ��  ��  ��  ��  0 k  �>GG HIH l ����������  ��  ��  I JKJ n ��LML I  ����N���� 0 	mylogthis 	MyLogThisN O��O b  ��PQP b  ��RSR b  ��TUT b  ��VWV b  ��XYX b  ��Z[Z m  ��\\ �]]  P r o c e s s i n g  [ o  ������ 0 	albumname 	albumNameY m  ��^^ �__    (W l ��`����` c  ��aba o  ������ 0 cnt  b m  ����
�� 
ctxt��  ��  U m  ��cc �dd  /S l ��e����e c  ��fgf l ��h����h I ����i��
�� .corecnte****       ****i 2 ����
�� 
IPal��  ��  ��  g m  ����
�� 
ctxt��  ��  Q m  ��jj �kk  ) . . .��  ��  M  f  ��K lml l ����������  ��  ��  m n��n Z  �>op����o H  ��qq l ��r����r C  ��sts o  ������ 0 	albumname 	albumNamet o  ������ 0 gsmartalbum gSmartAlbum��  ��  p k  �:uu vwv l ����������  ��  ��  w xyx l ����z{��  z ' ! Generate destination folder name   { �|| B   G e n e r a t e   d e s t i n a t i o n   f o l d e r   n a m ey }~} r  ��� n ����� I  ��������� .0 mypathtoalbumorfolder MyPathToAlbumOrFolder� ���� o  ������ 0 onealbum oneAlbum��  ��  �  f  ��� o      ���� 0 albumfolder albumFolder~ ��� l ����������  ��  ��  � ��� n ����� I  ��������� 0 	mylogthis 	MyLogThis� ���� b  ����� m  ���� ��� 2 # M a n a g i n g   t h e   d i r e c t o r y :  � o  ������ 0 albumfolder albumFolder��  ��  �  f  ��� ��� r  ����� m  ����
�� boovfals� o      �� 0 	newfolder 	newFolder� ��� l ���~�}�|�~  �}  �|  � ��� Z  �~���{�z� H  ���� o  ���y�y 0 	gnoaction 	gNoAction� k  �z�� ��� l ���x�w�v�x  �w  �v  � ��� l ���u���u  � $  Create the destination folder   � ��� <   C r e a t e   t h e   d e s t i n a t i o n   f o l d e r� ��t� O  �z��� k  �y�� ��� Z  �6���s�r� F  ����� l ����q�p� I ���o��n
�o .coredoexnull���     obj � o  ���m�m 0 albumfolder albumFolder�n  �q  �p  � l ����l�k� = ����� o  ���j�j 0 freplace fReplace� m  ���i
�i boovtrue�l  �k  � k  �2�� ��� n ���� I  ��h��g�h 0 	mylogthis 	MyLogThis� ��f� b  � ��� m  ���� ��� * # R e m o v i n g   d i r e c t o r y :  � o  ���e�e 0 albumfolder albumFolder�f  �g  �  f  ��� ��� l ���� I �d��c
�d .sysoexecTEXT���     TEXT� b  ��� m  �� ���  r m   - f r  � n  ��� 1  �b
�b 
strq� l ��a�`� n  ��� 1  �_
�_ 
psxp� o  �^�^ 0 albumfolder albumFolder�a  �`  �c  � &   purge the folder in destination   � ��� @   p u r g e   t h e   f o l d e r   i n   d e s t i n a t i o n� ��� l ,���� I ,�]��\
�] .sysoexecTEXT���     TEXT� b  (��� m  �� ���  m k d i r   - p  � n  '��� 1  #'�[
�[ 
strq� l #��Z�Y� n  #��� 1  #�X
�X 
psxp� o  �W�W 0 albumfolder albumFolder�Z  �Y  �\  � ' ! create the folder in destination   � ��� B   c r e a t e   t h e   f o l d e r   i n   d e s t i n a t i o n� ��V� r  -2��� m  -.�U
�U boovtrue� o      �T�T 0 	newfolder 	newFolder�V  �s  �r  � ��S� Z  7y���R�� H  7?�� l 7>��Q�P� I 7>�O��N
�O .coredoexnull���     obj � o  7:�M�M 0 albumfolder albumFolder�N  �Q  �P  � k  Bh�� ��� n BN��� I  CN�L��K�L 0 	mylogthis 	MyLogThis� ��J� b  CJ��� m  CF�� ��� * # C r e a t i n g   d i r e c t o r y :  � o  FI�I�I 0 albumfolder albumFolder�J  �K  �  f  BC� ��� l Ob���� I Ob�H��G
�H .sysoexecTEXT���     TEXT� b  O^��� m  OR�� ���  m k d i r   - p  � n  R]��� 1  Y]�F
�F 
strq� l RY��E�D� n  RY   1  UY�C
�C 
psxp o  RU�B�B 0 albumfolder albumFolder�E  �D  �G  � ' ! create the folder in destination   � � B   c r e a t e   t h e   f o l d e r   i n   d e s t i n a t i o n� �A r  ch m  cd�@
�@ boovtrue o      �?�? 0 	newfolder 	newFolder�A  �R  � k  ky  n kw	
	 I  lw�>�=�> 0 	mylogthis 	MyLogThis �< b  ls m  lo � * # E x i s t i n g   d i r e c t o r y :   o  or�;�; 0 albumfolder albumFolder�<  �=  
  f  kl �: l xx�9�8�7�9  �8  �7  �:  �S  � m  ���                                                                                  MACS  alis    ,  Ra                             BD ����
Finder.app                                                     ����            ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    R a  &System/Library/CoreServices/Finder.app  / ��  �t  �{  �z  �  l �6�5�4�6  �5  �4    r  � l ��3�2 e  � n  � 2 ���1
�1 
IPmi 4  ��0
�0 
IPal o  ���/�/ 0 	albumname 	albumName�3  �2   o      �.�. 0 	allphotos 	allPhotos  l ���-�,�+�-  �,  �+    !  l ���*"#�*  " ; 5 Building the list of media not in destination folder   # �$$ j   B u i l d i n g   t h e   l i s t   o f   m e d i a   n o t   i n   d e s t i n a t i o n   f o l d e r! %&% Z  �9'(�))' o  ���(�( 0 	newfolder 	newFolder( k  ��** +,+ n ��-.- I  ���'/�&�' 0 	mylogthis 	MyLogThis/ 0�%0 b  ��121 b  ��343 m  ��55 �66  # E x p o r t i n g  4 l ��7�$�#7 c  ��898 l ��:�"�!: n  ��;<; 1  ��� 
�  
leng< o  ���� 0 	allphotos 	allPhotos�"  �!  9 m  ���
� 
ctxt�$  �#  2 m  ��== �>>    i t e m s . . .�%  �&  .  f  ��, ?�? r  ��@A@ o  ���� 0 	allphotos 	allPhotosA o      �� *0 mediaitemstoattempt mediaItemsToAttempt�  �)  ) k  �9BB CDC n ��EFE I  ���G�� 0 	mylogthis 	MyLogThisG H�H b  ��IJI b  ��KLK m  ��MM �NN  # C h e c k i n g  L l ��O��O c  ��PQP l ��R��R n  ��STS 1  ���
� 
lengT o  ���� 0 	allphotos 	allPhotos�  �  Q m  ���
� 
ctxt�  �  J m  ��UU �VV    i t e m s . . .�  �  F  f  ��D WXW r  ��YZY J  ����  Z o      �� *0 mediaitemstoattempt mediaItemsToAttemptX [�[ X  �9\�]\ k  �4^^ _`_ r  �aba c  ��cdc b  ��efe b  ��ghg o  ���� 0 albumfolder albumFolderh m  ��ii �jj  :f l ��k��
k n  ��lml 1  ���	
�	 
filnm o  ���� 0 	mediaitem 	mediaItem�  �
  d m  ���
� 
TEXTb o      �� "0 filenametocheck FilenameToCheck` n�n O  4opo Z  3qr��q H  ss l t��t I � u��
�  .coredoexnull���     obj u 4  ��v
�� 
filev o  ���� "0 filenametocheck FilenameToCheck��  �  �  r k  /ww xyx n (z{z I  (��|���� 0 	mylogthis 	MyLogThis| }��} b  $~~ b   ��� m  �� ���  # C h e c k i n g   f i l e  � o  ���� "0 filenametocheck FilenameToCheck m   #�� ���   :   d o e s   n o t   e x i s t��  ��  {  f  y ���� r  )/��� o  )*���� 0 	mediaitem 	mediaItem� n      ���  ;  -.� o  *-���� *0 mediaitemstoattempt mediaItemsToAttempt��  �  �  p m  ���                                                                                  MACS  alis    ,  Ra                             BD ����
Finder.app                                                     ����            ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    R a  &System/Library/CoreServices/Finder.app  / ��  �  � 0 	mediaitem 	mediaItem] o  ������ 0 	allphotos 	allPhotos�  & ��� l ::��������  ��  ��  � ��� l ::������  �   Any work to do?   � ���     A n y   w o r k   t o   d o ?� ��� Z  :������� =  :C��� l :A������ I :A�����
�� .corecnte****       ****� o  :=���� *0 mediaitemstoattempt mediaItemsToAttempt��  ��  ��  � m  AB����  � n FZ��� I  GZ������� 0 	mylogthis 	MyLogThis� ���� b  GV��� b  GR��� b  GN��� m  GJ�� ��� J # N o   m e d i a   t o   e x p o r t   f r o m   a l b u m   n a m e :  � o  JM���� 0 	albumname 	albumName� m  NQ�� ���    i n   d i r e c t o r y :  � o  RU���� 0 albumfolder albumFolder��  ��  �  f  FG��  � Z  ]������� o  ]^���� 0 	gnoaction 	gNoAction� n a���� I  b�������� 0 	mylogthis 	MyLogThis� ���� b  b��� b  b{��� b  bw��� b  bs��� b  bo��� m  be�� ���  # W o u l d   e x p o r t  � l en������ c  en��� l el������ I el�����
�� .corecnte****       ****� o  eh���� *0 mediaitemstoattempt mediaItemsToAttempt��  ��  ��  � m  lm��
�� 
ctxt��  ��  � m  or�� ��� 2   p h o t o s   f r o m   a l b u m   n a m e :  � o  sv���� 0 	albumname 	albumName� m  wz�� ���    i n   d i r e c t o r y :  � o  {~���� 0 albumfolder albumFolder��  ��  �  f  ab��  � t  ����� l ������ k  ���� ��� n ����� I  ��������� 0 	mylogthis 	MyLogThis� ���� b  ����� b  ����� b  ����� b  ����� b  ����� m  ���� ���  # E x p o r t i n g  � l �������� I �������
�� .corecnte****       ****� o  ������ *0 mediaitemstoattempt mediaItemsToAttempt��  ��  ��  � m  ���� ��� 2   p h o t o s   f r o m   a l b u m   n a m e :  � o  ������ 0 	albumname 	albumName� m  ���� ���    i n   d i r e c t o r y :  � o  ������ 0 albumfolder albumFolder��  ��  �  f  ��� ��� l ������ I ������
�� .IPXSexponull���     ****� o  ������ *0 mediaitemstoattempt mediaItemsToAttempt� ����
�� 
insh� l �������� c  ����� o  ������ 0 albumfolder albumFolder� m  ����
�� 
alis��  ��  � �����
�� 
usMA� m  ����
�� boovtrue��  � $   export the original versions   � ��� <     e x p o r t   t h e   o r i g i n a l   v e r s i o n s� ���� r  ����� [  ����� o  ������ 0 nbphotos nbPhotos� l �������� I �������
�� .corecnte****       ****� o  ������ *0 mediaitemstoattempt mediaItemsToAttempt��  ��  ��  � o      ���� 0 nbphotos nbPhotos��  � , & give 4 hours instead of 2 minutes ...   � ��� L   g i v e   4   h o u r s   i n s t e a d   o f   2   m i n u t e s   . . .� m  ������8@� ��� l ����������  ��  ��  � ��� l ��������  �   Write status   � �      W r i t e   s t a t u s�  Z  �8���� H  �� o  ������ 0 	gnoaction 	gNoAction k  �4  r  �	
	 b  �  b  �� b  �� b  �� l ������ c  �� l ������ I ��������
�� .misccurdldt    ��� null��  ��  ��  ��   m  ����
�� 
TEXT��  ��   m  �� �    -   l ������ c  �� l ������ I ������
�� .corecnte****       **** o  ������ *0 mediaitemstoattempt mediaItemsToAttempt��  ��  ��   m  ����
�� 
ctxt��  ��   m  �� �    /   l �� ����  c  ��!"! l ��#����# n  ��$%$ 1  ����
�� 
leng% o  ������ 0 	allphotos 	allPhotos��  ��  " m  ����
�� 
TEXT��  ��  
 o      ���� 0 thetext theText &'& r  ()( c  *+* b  ,-, o  ���� 0 albumfolder albumFolder- m  .. �//  : s t a t u s . t x t+ m  ��
�� 
TEXT) o      ���� 0 thefile theFile' 0��0 I 4��1��
�� .sysoexecTEXT���     TEXT1 b  0232 b  $454 b   676 m  88 �99 
 e c h o  7 n  :;: 1  ��
�� 
strq; o  ���� 0 thetext theText5 m   #<< �==    > >  3 n  $/>?> 1  +/��
�� 
strq? l $+@����@ n  $+ABA 1  '+��
�� 
psxpB o  $'���� 0 thefile theFile��  ��  ��  ��  ��  ��   C��C l 99��������  ��  ��  ��  ��  ��  ��  ��  �� 0 onealbum oneAlbum 2 >C��
�� 
IPal��  �   not cancelled   � �DD    n o t   c a n c e l l e d��  ��  � E��E n HfFGF I  If��H���� 0 	mylogthis 	MyLogThisH I��I c  IbJKJ b  I^LML b  IXNON l ITP����P c  ITQRQ b  IPSTS m  ILUU �VV  # E n d :  T o  LO���� 0 nbphotos nbPhotosR m  PS��
�� 
TEXT��  ��  O m  TWWW �XX    a t  M l X]Y��~Y I X]�}�|�{
�} .misccurdldt    ��� null�|  �{  �  �~  K m  ^a�z
�z 
TEXT��  ��  G  f  HI��  9 m   " #ZZl                                                                                  Phts  alis      Ra                             BD ����
Photos.app                                                     ����            ����  
 cu             Applications  /:Applications:Photos.app/   
 P h o t o s . a p p    R a  Applications/Photos.app   / ��  �T  �S  6 [\[ l     �y�x�w�y  �x  �w  \ ]^] l     �v�u�t�v  �u  �t  ^ _`_ l     �sab�s  a + % display destination folder in Finder   b �cc J   d i s p l a y   d e s t i n a t i o n   f o l d e r   i n   F i n d e r` ded l h�f�r�qf O  h�ghg k  n�ii jkj I nw�pl�o
�p .aevtodocnull  �    alisl l nsm�n�mm c  nsnon o  no�l�l 0 gdest gDesto m  or�k
�k 
alis�n  �m  �o  k p�jp L  x�qq b  x�rsr J  x}tt u�iu m  x{vv �ww  D o n e :  �i  s o  }��h�h 0 
albumnames 
albumNames�j  h m  hkxx�                                                                                  MACS  alis    ,  Ra                             BD ����
Finder.app                                                     ����            ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    R a  &System/Library/CoreServices/Finder.app  / ��  �r  �q  e y�gy l     �f�e�d�f  �e  �d  �g       �cz{|}�c  z �b�a�`�b .0 mypathtoalbumorfolder MyPathToAlbumOrFolder�a 0 	mylogthis 	MyLogThis
�` .aevtoappnull  �   � ****{ �_ q�^�]~�\�_ .0 mypathtoalbumorfolder MyPathToAlbumOrFolder�^ �[��[ �  �Z�Z 0 targetobject targetObject�]  ~ �Y�X�W�V�U�T�Y 0 targetobject targetObject�X 0 	theobject 	theObject�W 0 thepath thePath�V 0 
foldername 
folderName�U 0 thisid thisID�T 0 	albumname 	albumName �S ��R�Q�P ��O�N�M ��L�K�J �
�S 
pnam
�R 
pare
�Q 
pcls
�P 
IPfd
�O 
ID  
�N kfrmID  
�M 
IPal�L  �K  �J 0 gdest gDest�\ ��E�O��,E�O� z whZ ^��,�,�  $��,�,E�O��%�%E�O��,�,E�O*��0E�Y /��,�,�  $��,�,E�O��%�%E�O��,�,E�O*��0E�Y hW X 
 ��%�%E�O�[OY��U| �I ��H�G���F�I 0 	mylogthis 	MyLogThis�H �E��E �  �D�D 0 thetext theText�G  � �C�B�C 0 thetext theText�B 0 thefile theFile� �A�@�?�>�=�<�;�:�9 �8�7
�A .ascrcmnt****      � ****
�@ 
appr�? 0 apptitle  
�> .sysonotfnull��� ��� TEXT
�= afdrdown
�< 
rtyp
�; 
ctxt
�: .earsffdralis        afdr
�9 
strq
�8 
psxp
�7 .sysoexecTEXT���     TEXT�F 7�j  O�� ���l Y hO���l �%E�O��,%�%��,�,%j } �6��5�4���3
�6 .aevtoappnull  �   � ****� k    ���  ��  ��  %��  8��  D��  M�� 5�� d�2�2  �5  �4  � �1�0�1 0 onealbum oneAlbum�0 0 	mediaitem 	mediaItem� u �/�.�- 0�,�+�* =�)�(�'Z�&�%Q�$�#�"\�!� u�����������������������������
��	�����BD\^cj����� �������������5=��MUi��������������������������.��8<UW��v�/ 0 apptitle  
�. 
bool�- "0 allowusertodest allowUserToDest
�, 
psxf
�+ 
ctxt�* 0 gdest gDest�) 0 gsmartalbum gSmartAlbum�( 0 	gnoaction 	gNoAction�' 20 allowusertoselectalbums allowUserToSelectAlbums�&`
�% .miscactvnull��� ��� null
�$ .misccurdldt    ��� null
�# 
TEXT�" 0 	mylogthis 	MyLogThis�! 0 nbphotos nbPhotos
�  
prmp
� 
dflc
� 
alis� 
� .sysostflalis    ��� null
� 
rslt
� 
psxp� 0 conffile confFile
� 
IPal
� 
pnam� 0 allalbumnames allAlbumNames
� 
mlsl
� .gtqpchltns    @   @ ns  � 0 
albumnames 
albumNames
� 
btns
� 
dflt
� 
disp
� 
givu� 

� 
appr
� .sysodlogaskr        TEXT
� 
bhit�
 0 freplace fReplace�	 0 cnt  
� 
leng
� 
kocl
� 
cobj
� .corecnte****       ****� 0 	albumname 	albumName� .0 mypathtoalbumorfolder MyPathToAlbumOrFolder� 0 albumfolder albumFolder� 0 	newfolder 	newFolder
�  .coredoexnull���     obj 
�� 
strq
�� .sysoexecTEXT���     TEXT
�� 
IPmi�� 0 	allphotos 	allPhotos�� *0 mediaitemstoattempt mediaItemsToAttempt
�� 
filn�� "0 filenametocheck FilenameToCheck
�� 
file��8@
�� 
insh
�� 
usMA
�� .IPXSexponull���     ****�� 0 thetext theText�� 0 thefile theFile
�� .aevtodocnull  �    alis�3��E�Of�&E�O��&�&E�O�E�Of�&E�Of�&E�O�B�n*j oO)�*j %a &k+ O)a �%k+ OjE` O� 8*a a a �a &a  E` O_ a ,�&�&�&E�O�a %E` Y hO)a �%k+ O*a  -a !,E` "O� _ "a a #a $ea  %E` &Y 	_ "E` &Oa 'a (a )a *lva +la ,la -a .a /�a . 0E` O_ a 1,a 2 E` 3O)a 4_ 3%�&k+ O_ &f*jE` 5O)a 6_ &a 7,�&%a 8%k+ O*a  -[a 9a :l ;kh  _ 5kE` 5O�a !,E` <O_ &_ < )a =_ <%a >%k+ OPY�)a ?_ <%a @%_ 5�&%a A%*a  -j ;�&%a B%k+ O_ <��)�k+ CE` DO)a E_ D%k+ OfE` FO� �a G �_ Dj H	 	_ 3e �& ?)a I_ D%k+ Oa J_ Da ,a K,%j LOa M_ Da ,a K,%j LOeE` FY hO_ Dj H +)a N_ D%k+ Oa O_ Da ,a K,%j LOeE` FY )a P_ D%k+ OPUY hO*a  _ </a Q-EE` RO_ F #)a S_ Ra 7,�&%a T%k+ O_ RE` UY �)a V_ Ra 7,�&%a W%k+ OjvE` UO b_ R[a 9a :l ;kh _ Da X%�a Y,%a &E` ZOa G -*a [_ Z/j H )a \_ Z%a ]%k+ O�_ U6FY hU[OY��O_ Uj ;j  )a ^_ <%a _%_ D%k+ Y x� ')a `_ Uj ;�&%a a%_ <%a b%_ D%k+ Y Oa cn)a d_ Uj ;%a e%_ <%a f%_ D%k+ O_ Ua g_ Da &a hea  iO_ _ Uj ;E` oO� `*j a &a j%_ Uj ;�&%a k%_ Ra 7,a &%E` lO_ Da m%a &E` nOa o_ la K,%a p%_ na ,a K,%j LY hOPY h[OY�Y hO)a q_ %a &a r%*j %a &k+ UOa G �a &j sOa tkv_ &%U ascr  ��ޭ