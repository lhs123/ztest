*&---------------------------------------------------------------------*
*& Report ZWS_SAP_OO2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZWS_SAP_OO2.
CLASS a1 DEFINITION.
  PUBLIC SECTION.
    METHODS :constructor ,
              m1,m2.
ENDCLASS.

CLASS a2 DEFINITION INHERITING FROM a1.
  PUBLIC SECTION.
    METHODS: constructor ,
              m1 REDEFINITION,m2 REDEFINITION,
              m3.
ENDCLASS.

CLASS a1 IMPLEMENTATION.
  METHOD: constructor.
    "调用的是父类中的方法，而不是子类被重写的方法，这与Java不一样
    me->m1( ).
  ENDMETHOD.
  METHOD: m1.
    WRITE: / 'a1~m1'.
    "即使不是在父类构造器中调用被重写方法也是这样的，与Java不一样
    me->m2( ).
  ENDMETHOD.
  METHOD: m2.
    WRITE: / 'a1~m2'.
  ENDMETHOD.
ENDCLASS.

CLASS a2 IMPLEMENTATION.
  METHOD: constructor.
    super->constructor( ).
    SKIP.
    me->m1( ).
  ENDMETHOD.
  METHOD: m1.
    WRITE: / 'a2~m1'.
    me->m2( ).
  ENDMETHOD.
  METHOD: m2.
    WRITE: / 'a2~m2'.
  ENDMETHOD.
  METHOD m3.
    WRITE:/ 'a2~m3'.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA: o TYPE REF TO a1.
  CREATE OBJECT o TYPE a2.
  SKIP.
  o->M1( ).

*  DATA: o1 TYPE REF TO a2.
*  CREATE OBJECT o1.
*  SKIP.
*  o1->M3( ).
*                                                ............ ...
*                                         ....:::,,,,;;;;;,,,,,::.. ...
*                                     .::;;iittjjjjjfffffffjjjtti;:::..
*                                   ..,iiffLLGDDDDDDDEEEEEEEEDDGLjti,:. .
*                                 :,itjffGGDDGGGGGLLLLfLLLLLLGGGLffftii;:. .
*                              .:,ijGDDDGDDGLjjttii;;,,,,,;;;ttjLLGGGGLjt;::.
*                          ..:,ijfLGGLfjjttti;;;;,:.:::::::::,;ittjfLGGGGfti,.
*                         .::;tLGDGLjti;,,:::::,,::.:::,:::.:::,,;;ittjfGGGft;:.
*                       .:;itLGGDLfi,::........:::..:::,,,:::.::::.::,;ijfGDDLt;:..
*                       :ijfLLGLfji,.....:::,..:....:::::::..:...::::::,;ifGGGLji,:.
*                      :;jLLGLft;,:..::.:::,,......::::....:.::.::.::::::,;tfGDGLt;:.
*                    .:;tfGLfji::...:,:::::::...:::::::::::::::::::::::::::,ijLDGLj;:
*                    :;jfLfft;:...:::::::::::..::::::::.:::..::::::::::::::.:,tfLGLj;:.
*                  .:;jLLji;,:..:::,:::.:,;;;,,,,::::::::,:::.:.:::.:::,:,:,::,itLDGfi:
*                 .:,tfLfi,::.:::.:::::,,tjfjti;;,:::..::::,,,::::.:::::::,::::,;jLGLj;:.
*                 :;tffft,::::::::::,,;itLGGLfjjti,...::,,;ii;;,,::::..:::,:::.::;tLGLt;.
*                .:ifLft;:::..:..::,;ijLLGGGLLLLLji:::,;itjffjjt;;,::.:::::::::::,;jLGft,.
*                .ifLfji,:::::::.:,,ijLGLjjjjjjfGLj;,;tfLLfLLLfLfj;:.:::....::::::,ijLGfi:
*              ..:jDLj;,,::,::::.:;;jLGft,,,::,iLDDfijDEDLjjjffLGLj;,:.::.::.::::::,;jLDL,.
*                :fDLi,,:::,::::.:,;fGft,. ....:tLGGjfDDLji;;itjLGLj;,:...::::::,,::,iLDG;.
*               .,LDf;,,::::::::::;ifGj;:::.....,iLDGGLLt;,:::,;tLGLi,:...::::::,,:.:ifGGi:
*               :;GGj,::::::::::::;iLGjtti,:... .,fEEGfji,:....:,jDGj;:....::::::,:.:,tLDj;
*               ,jDGt:::::::::::::,tGDLfLft,..  .,fKEGftti,:....:iGDf;::::::::::::::::;fDLt.
*              .;fGL;:::::::::::::;tLDLLEELt:.. .,fEDLjjfGf;:...:;jLL;,,::::::::.::.::,tGGf:.
*              .iLGf;:::::,:::::::;tLGffGDLt,:...,fDGfjfGEGt,....,tLf;,,,:.:::::::..:.:;fGL:.
*              :tGLj;:::::,:::,::,;tLLtitfjt;:..:iLDDGffLDLt,....,tLf;,,,,:::::::::::.:;jGG,.
*              :tGft,:::::,:::,::,;tfGjiii;,,::,ijLGEGfjjjti:...:;jGf;,,,,::,::::::::.:,tGG;:
*              ,jGji,::,,,,,,,,:,,;tfLLtii,::.,ifLLGDGji;;,,:...,tGGf;,:,:.,:::::::::::,tGGi:
*             .;jGt,,::,:,,,;,,,,,,;tfGGLt;::,ifDDLLDGfi,:::...:ifDGj,::::::,:::::.:::,,iGDt,
*             .;fG;,,::::,;,;;;,,,:,;tLGGfjtitfGEELLGDGji;:....,tGGLt,:.:..:,:::::.::,,,iGDt,.
*            .:ifG;:,,:,,;;;;i;,,,::,;tfGDDGGGDEEEGGDKKDft,:,,,ifGGfi,:::::::::::,::::,,iGDt,.
*            .,fGG;,,,,,,;iiii;;,,::::;ifDEEEKKEEDGGDEEEDGLfjfjfLLji,,::::::::::::::::,,iLDt,
*            .;fDG;,:,,,,;;iiii;;,::::,;jDEEDDGGGGLGGDGGEKKEEDGLjti;,::::::,::::::::::,,iLDt,
*            .iLLf;::,;;,;iiii;;;,::::;tfGGLfjtitttjjjjfLDDDDLfjti;,,,,,,,,,::::::::::,:iLDt,
*           .:tGLj,::,,;;;;ii;;;;,:::,tfGGLjttii;iiiiitjfLGGGfi;;,;;;;;;,,,,,:::::::::::;LDt,
*           .,jGLt:.:,,;;;;;;;;;;,,,:,jGGGLfjffjtttiitttjfLLLt;,,,;i;;ii;;;,,:::::::::::;LDj,
*           :;jDfi:.:,,,,;i;;;;;,,,::,jGDDGGGGGLLfjjjffjtjLGLj;,,;;;iiiiii;,,,:::::::::.;LDj;
*          .:;jGj;:.:,,,,;;;;;;;,,,::,jDDDGGGDDDDGGLGGGfjjGDDfi,;;;;iiitii;;,,:::::::::.;LDj;
*           :;fDj;:.:,,,,;;,;;;,,,:::,jGDDGLffLLGGLLGDEGLLGDGf;,,;;iiiiiii;;,,:::,:::::.;LDj;
*           :;fDf;:.:::,,,,;;;,,,::::,tLDGLfttttjfjjfLGGLLDDDfi,,,,iiiiii;;;,,:::,::::::;LDj,
*           .,jGft,::::::,,,,,,::::::,ifGDGftiiii;;;;itjfLDGGj;,,,;i;;i;;;,;,::::,::::::iLGt,
*            :tLLj;,:::::,,,,,,,:::::,;tfDGLjjttiii;;;ijLGDGft;,,;;;;;;;;,,,,::::,::.:,,iGDi:
*            .iLGLi,:::::,,,,,,:::::::,;jGGGLLLjjjtittjjLGLjt;;,,,,,,,,;;,,::::::,::.:,,iGGi:
*            .;fGGji,::::::,:,,::::::::,;jfLLGDDDDDGGGGGGGfti,,:::,,,,,,,,,:::::::::::,;jGG;.
*             :tLLLji,,::::::::::::::::::;ijfLLLGGGGGGLLfft;,,:::::::::::::::::::::::.,iLGL,.
*           ..:;jLGGfi;::::::::::::::::::::,;;ttjjjjttti;,,,,:::::::::::::::::::::,,::;jDGf:
*         .:,;ijLGGLji,::::::::::::::::::::::,,,;;;;;,,,::::::::::::::::::::::::::,,:,ifDGf:
*       ..:;tjLGDDGft,::::::::::::::::::::::::::,:,::::::::::::::::::::::::::::::::::;jLDLt:.
*       :;tfGGLLLft;,:::::::::::::::::::::::::::::::::::::::::,,:::::::::::::::::,:::tLGLj;..
*   .  .,tjLGLfjti;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,::,tLGLt,
*   ..:,tfLLfti;,::...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,:.,tLGGt,.
*....:;tfGGjt;,::.:....::::::::::::::::::::::::::::::::::::::,::::::::::::::::::::::,ijLGfi.
* ..:;tLGLj;,::...::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,;tfLLj,.
*  .,tGEGji,,:::.::,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,,;tLGLt,.
* .:tLGDfi,,:::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,ijLGft,.
*.:tLDLfi::::::...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,ijLGfi,:
*;tfGGji:::::::.:::,,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::,;tGGfi,
*fLDGf;:..:::.::::,,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:;fGLji.
*EEDfi:...:,::::::,:::::::::::::::::::::::::::::::::::,:::::::::::::::,::::::::::::::::..:,ijLGj:
*EDGt,:...,;;,::::,::::::::::::::.::::::::::::::::::::G:::::::::::::::G::::::::::::::::.:,,,ifEL;.
*GGfi:....,tt;,,::::::::::::::fGGGGGGGGGGG::::::::::::D::::::GGDGDG:::G::::::::::::::::.:,,:;jEDt:.
*GLj,: ..:;jfi;:::::::::::::::fDDDDDGDDDDD:::;iii:GGGGDGGGG,:GLLDLG:GGGGGG,::::::::::::.:,,:,tGDLi.
*LLt,...:,ifft;,:::::::::::::::::::;G::::::::fGDG:GLfffffff,:G;:G:G:GGGGGG::::::::::,::.:,,.:;fDDj.
*DLt:. .:;jfft;,::::::.::::::::::::;D::::::::ft,G:G::::::::::G;:G:G:G::::D:::::::::::,:.:;,:.:tGKL:
*ELi: .:;tfjji;,:::::::::::::::::::;D::::::::fi:G:G:iL::,L:::G;:G:G:G:G::G:::::::::::,::,;i:.:;jEL;:.
*KGt,..:ijLjt,,::::::::::::::::::::;D::::::::fi:G:G:;f::,L:::G;:G:G:G:;D:G::::::::::::::,it;::,tDLt,,
*KDf;::,jLGj;:.::::::::::::::::::::;D::::::::ft,G,G:;f::,L:::GGDGGD:G::G:D::::::::::::,,;tjt;::iGGj;,
*DGLt;;ifLGt,...:::::::::::::::::::;G::::::::fi,G,GDGDGGDGG::GLfGLD:G:.::G:::::::::::::,ijfji::iLGf;:
*ffLLfjfLLf;:...:::::::::::::::::::;G::::::::ft:G:GGDGGGGGG::G;:G:G:G::fGG:::::::,:::,:,ifLfi,:;jLL;.
*itLGGLGGft:..:::::::::::::::DGGGGGGGGGGGGG;:ft:G:G:Gf::GG:::G;:G:G:G::GD,::::::::::::,,iLGfi,:;jLGi.
*.,tLGDDGfi::::::::::::::::::DGGGGGGGGGGGGG,:ft:G:G:GD::GL:::G;:G:G:G:::::::::::::::::::ifLfi::,tLDi:
* .,tfDEGj;::::::::::::::::::::::::;G.:::::::ft:G,G:LG;:jL,::G;:G:G:DGGGLGG:::::::::::::;jfLt,::iLDj;
*  .:;LDLt,.:::::::::::::::::::::::;D::::::::fi:G;L,tfG;;Li::GGDGGG:GGGGGDG::::::::::::::ijGj;,:,fDLt
* . .;LDfi,.:::::.:::::::::::::::::;G::::::::ft:Gtfj;fLf;LL::G;,D:D:::::::G::::::::::::::;jDfi:.:jDLj
*   :;LDji,::::::::::::::::::::::::;G::::::::ft,GLiG;L:D;LG::G;,G:G:::::::G::::::::::::::;jGfi:.:tDft
*   :iLDj;:.:::::::::::::::::::::::;D::::::::fGGGG,G;f:G,LG:::::G::fGGGGG:G:::::::::::::,;tGGt:.:jDft
*   :iLGt;::..:::::::::::::::::::::;D::::::::ft::G:G;f;f,Lf;::::G::LGGGGG:G:::::::::::::,;tGGf,.:jGft
*   ,jGGt,:.:::::::::::::::::::::::;D::::::::fi::D;;;fL,,L,G:::,G:::::::::D:::::::.:::::,;tGDL,.:tLji
*   ,jLGi,:.:::::::::::::::::::::::;D:::::::::::,G,:;f::,L::::::G:::::::::G::::::::::::::,iLGL,:,jLt;
*   ,fLL;::::::::::::::::::::::::::;G:::::::::::fL::;f::,L:::::,G::::::::;G:::::::,::::::,iLGL;:;jLt;
*   ;LLf;::::::::::::::::::::::::::;G:::::::::::G,::;f::,L:::::,G::::::GGGj::::::::::::::,;fGL;,iffi:
*   iLLf,.:::::::::::::::::::::::::;G.::::::::::;:::;f::,L::::::G::::::GGf:::::::..ii:;ii,;ii;,:;;;:.
*   iLLj,.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:::::::;::.:.::.;i.ittt;i
*  .iGGf,.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;,:i,:::i;jf,.jiLji
*  .;GGf,.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::ittiitjititGGLGGLLt.
*  .;GGf,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::jijjjjjjjf,,jD,j,:t
*   ;LGf;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.ffLi...:jfGjEDiGtfj.
*   ;LGf;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:ifGji,:. .
