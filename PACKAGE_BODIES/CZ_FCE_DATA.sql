--------------------------------------------------------
--  DDL for Package Body CZ_FCE_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_FCE_DATA" AS
/*	$Header: czfcesdb.pls 120.34.12010000.2 2008/10/20 17:54:04 asiaston ship $		*/
---------------------------------------------------------------------------------------
PROCEDURE populate_fce_data IS
BEGIN

--Many of the following data is seeded and can be looked up every time logic gen starts.
--This may be an overhead when the seed data does not change often, so it may be a good
--idea to hardcode this data and have a special procedure that will re-populate it when
--necessary.

     cz_fce_compile.h_psntypes('component')            := 259;
     cz_fce_compile.h_psntypes('root')                 := 2591;
     cz_fce_compile.h_psntypes('singleton')            := 2592;
     cz_fce_compile.h_psntypes('feature')              := 261;
     cz_fce_compile.h_psntypes('optionfeature')        := 0;
     cz_fce_compile.h_psntypes('integerfeature')       := 1;
     cz_fce_compile.h_psntypes('decimalfeature')       := 2;
     cz_fce_compile.h_psntypes('booleanfeature')       := 3;
     cz_fce_compile.h_psntypes('option')               := 262;
     cz_fce_compile.h_psntypes('reference')            := 263;
     cz_fce_compile.h_psntypes('connector')            := 264;
     cz_fce_compile.h_psntypes('total')                := 272;
     cz_fce_compile.h_psntypes('resource')             := 273;
     cz_fce_compile.h_psntypes('integertotal')         := 274;
     cz_fce_compile.h_psntypes('integerresource')      := 275;
     cz_fce_compile.h_psntypes('bommodel')             := 436;
     cz_fce_compile.h_psntypes('bomoptionclass')       := 437;
     cz_fce_compile.h_psntypes('bomstandard')          := 438;

     cz_fce_compile.h_psntypes('beginport')            := -1;
     cz_fce_compile.h_psntypes('endport')              := -2;
     cz_fce_compile.h_psntypes('beginstructure')       := -3;
     cz_fce_compile.h_psntypes('endstructure')         := -4;
     cz_fce_compile.h_psntypes('beginrule')            := -5;
     cz_fce_compile.h_psntypes('endrule')              := -6;

     cz_fce_compile.h_instantiability('nonvirtual')    := 0;
     cz_fce_compile.h_instantiability('optional')      := 1;
     cz_fce_compile.h_instantiability('mandatory')     := 2;
     cz_fce_compile.h_instantiability('connector')     := 3;
     cz_fce_compile.h_instantiability('instantiable')  := 4;

     cz_fce_compile.h_ruletypes('statement')           := 200;
     cz_fce_compile.h_ruletypes('companion')           := 300;
     cz_fce_compile.h_ruletypes('explicitcompat')      := 24;
     cz_fce_compile.h_ruletypes('designchart')         := 30;

     cz_fce_compile.h_ruleclasses('constraint')        := 0;
     cz_fce_compile.h_ruleclasses('default')           := 1;
     cz_fce_compile.h_ruleclasses('search')            := 2;

     cz_fce_compile.h_designtypes('primary')           := 5;
     cz_fce_compile.h_designtypes('defining')          := 1;
     cz_fce_compile.h_designtypes('optional')          := 3;

     cz_fce_compile.h_mathconstants('e')               := 0;
     cz_fce_compile.h_mathconstants('pi')              := 1;

     --------------------------------------------------------
     --               cz_exnexprtype_lkv                   --
     --------------------------------------------------------
     cz_fce_compile.h_exprtypes('operator')            := 200;
     cz_fce_compile.h_exprtypes('literal')             := 201;
     cz_fce_compile.h_exprtypes('node')                := 205;
     cz_fce_compile.h_exprtypes('property')            := 207;
     cz_fce_compile.h_exprtypes('punctuation')         := 208;
     cz_fce_compile.h_exprtypes('systemproperty')      := 210;
     cz_fce_compile.h_exprtypes('constant')            := 211;
     cz_fce_compile.h_exprtypes('argument')            := 221;
     cz_fce_compile.h_exprtypes('template')            := 222;
     cz_fce_compile.h_exprtypes('forall')              := 223;
     cz_fce_compile.h_exprtypes('iterator')            := 224;
     cz_fce_compile.h_exprtypes('where')               := 225;
     cz_fce_compile.h_exprtypes('compatible')          := 226;
     cz_fce_compile.h_exprtypes('operatorbyname')      := 229;
     cz_fce_compile.h_exprtypes('foralldistinct')      := 231;
     cz_fce_compile.h_exprtypes('nodebyname')          := 232;
     --------------------------------------------------------

     cz_fce_compile.h_datatypes('integer')             := 1;
     cz_fce_compile.h_datatypes('decimal')             := 2;
     cz_fce_compile.h_datatypes('boolean')             := 3;
     cz_fce_compile.h_datatypes('text')                := 4;
     cz_fce_compile.h_datatypes('translatable')        := 8;

     cz_fce_compile.h_javatypes('Object')              := 2;
     cz_fce_compile.h_javatypes('IInstanceQuantifier') := 17;
     cz_fce_compile.h_javatypes('IIntExprDef')         := 18;
     cz_fce_compile.h_javatypes('ILogicExprDef')       := 19;
     cz_fce_compile.h_javatypes('INumExprDef')         := 21;

     cz_fce_compile.h_templates('requires')            := 1;
     cz_fce_compile.h_templates('implies')             := 2;
     cz_fce_compile.h_templates('excludes')            := 3;
     cz_fce_compile.h_templates('negates')             := 4;
     cz_fce_compile.h_templates('logic')               := 21;
     cz_fce_compile.h_templates('numeric')             := 22;
     cz_fce_compile.h_templates('propertybased')       := 23;
     cz_fce_compile.h_templates('accumulator')         := 25;
     cz_fce_compile.h_templates('comparison')          := 27;
     cz_fce_compile.h_templates('name')                := 31;
     cz_fce_compile.h_templates('description')         := 32;
     cz_fce_compile.h_templates('options')             := 35;
     cz_fce_compile.h_templates('minvalue')            := 37;
     cz_fce_compile.h_templates('maxvalue')            := 38;
     cz_fce_compile.h_templates('minquantity')         := 39;
     cz_fce_compile.h_templates('maxquantity')         := 40;
     cz_fce_compile.h_templates('minselected')         := 41;
     cz_fce_compile.h_templates('maxselected')         := 42;
     cz_fce_compile.h_templates('selection')           := 46;
     cz_fce_compile.h_templates('state')               := 47;
     cz_fce_compile.h_templates('value')               := 48;
     cz_fce_compile.h_templates('quantity')            := 49;
     cz_fce_compile.h_templates('instancecount')       := 50;
     cz_fce_compile.h_templates('integervalue')        := 51;
     cz_fce_compile.h_templates('decimalvalue')        := 52;
     cz_fce_compile.h_templates('mininstances')        := 53;
     cz_fce_compile.h_templates('maxinstances')        := 54;
     cz_fce_compile.h_templates('decimalquantity')     := 55;
     cz_fce_compile.h_templates('selectioncount')      := 57;
     cz_fce_compile.h_templates('minconnections')      := 58;
     cz_fce_compile.h_templates('maxconnections')      := 59;
     cz_fce_compile.h_templates('connectioncount')     := 60;
     cz_fce_compile.h_templates('relativequantity')    := 85;
     cz_fce_compile.h_templates('assignquantity')      := 86;
     cz_fce_compile.h_templates('assigndecquantity')   := 87;
     cz_fce_compile.h_templates('relativedecquantity') := 88;
     cz_fce_compile.h_templates('beginswith')          := 300;
     cz_fce_compile.h_templates('endswith')            := 301;
     cz_fce_compile.h_templates('contains')            := 303;
     cz_fce_compile.h_templates('like')                := 304;
     cz_fce_compile.h_templates('matches')             := 305;
     cz_fce_compile.h_templates('anytrue')             := 306;
     cz_fce_compile.h_templates('alltrue')             := 307;
     cz_fce_compile.h_templates('aggregatesum')        := 308;
     cz_fce_compile.h_templates('subsetof')            := 309;
     cz_fce_compile.h_templates('union')               := 310;
     cz_fce_compile.h_templates('and')                 := 316;
     cz_fce_compile.h_templates('or')                  := 317;
     cz_fce_compile.h_templates('equals')              := 318;
     cz_fce_compile.h_templates('notequals')           := 320;
     cz_fce_compile.h_templates('min')                 := 321;
     cz_fce_compile.h_templates('max')                 := 322;
     cz_fce_compile.h_templates('truncate')            := 323;
     cz_fce_compile.h_templates('optionsof')           := 324;
     cz_fce_compile.h_templates('gt')                  := 350;
     cz_fce_compile.h_templates('lt')                  := 351;
     cz_fce_compile.h_templates('ge')                  := 352;
     cz_fce_compile.h_templates('le')                  := 353;
     cz_fce_compile.h_templates('doesnotbeginwith')    := 361;
     cz_fce_compile.h_templates('doesnotendwith')      := 362;
     cz_fce_compile.h_templates('doesnotcontain')      := 363;
     cz_fce_compile.h_templates('notlike')             := 364;
     cz_fce_compile.h_templates('concatenate')         := 365;
     cz_fce_compile.h_templates('totext')              := 366;
     cz_fce_compile.h_templates('none')                := 399;
     cz_fce_compile.h_templates('add')                 := 401;
     cz_fce_compile.h_templates('subtract')            := 402;
     cz_fce_compile.h_templates('neg')                 := 402;
     cz_fce_compile.h_templates('multiply')            := 403;
     cz_fce_compile.h_templates('ceiling')             := 405;
     cz_fce_compile.h_templates('floor')               := 406;
     cz_fce_compile.h_templates('round')               := 407;
     cz_fce_compile.h_templates('div')                 := 408;
     cz_fce_compile.h_templates('mod')                 := 409;
     cz_fce_compile.h_templates('pow')                 := 410;
     cz_fce_compile.h_templates('roundtonearest')      := 411;
     cz_fce_compile.h_templates('rounddowntonearest')  := 412;
     cz_fce_compile.h_templates('rounduptonearest')    := 413;
     cz_fce_compile.h_templates('ln')                  := 414;
     cz_fce_compile.h_templates('log')                 := 415;
     cz_fce_compile.h_templates('exp')                 := 416;
     cz_fce_compile.h_templates('abs')                 := 417;
     cz_fce_compile.h_templates('sqrt')                := 418;
     cz_fce_compile.h_templates('cos')                 := 431;
     cz_fce_compile.h_templates('acos')                := 432;
     cz_fce_compile.h_templates('cosh')                := 433;
     cz_fce_compile.h_templates('sin')                 := 434;
     cz_fce_compile.h_templates('asin')                := 435;
     cz_fce_compile.h_templates('sinh')                := 436;
     cz_fce_compile.h_templates('tan')                 := 437;
     cz_fce_compile.h_templates('atan')                := 438;
     cz_fce_compile.h_templates('tanh')                := 439;
     cz_fce_compile.h_templates('integerpow')          := 551;
     cz_fce_compile.h_templates('not')                 := 552;
     cz_fce_compile.h_templates('textequals')          := 553;
     cz_fce_compile.h_templates('textnotequals')       := 554;
     cz_fce_compile.h_templates('addsto')              := 712;
     cz_fce_compile.h_templates('subtractsfrom')       := 714;
     cz_fce_compile.h_templates('assign')              := 451;
     cz_fce_compile.h_templates('incmin')              := 452;
     cz_fce_compile.h_templates('decmax')              := 453;
     cz_fce_compile.h_templates('minfirst')            := 454;
     cz_fce_compile.h_templates('maxfirst')            := 455;

     cz_fce_compile.h_inst('nop')                      := cz_fce_compile_utils.unsigned_byte (0);
     cz_fce_compile.h_inst('iconst_m1')                := cz_fce_compile_utils.unsigned_byte (2);
     cz_fce_compile.h_inst('iconst_0')                 := cz_fce_compile_utils.unsigned_byte (3);
     cz_fce_compile.h_inst('iconst_1')                 := cz_fce_compile_utils.unsigned_byte (4);
     cz_fce_compile.h_inst('iconst_2')                 := cz_fce_compile_utils.unsigned_byte (5);
     cz_fce_compile.h_inst('iconst_3')                 := cz_fce_compile_utils.unsigned_byte (6);
     cz_fce_compile.h_inst('iconst_4')                 := cz_fce_compile_utils.unsigned_byte (7);
     cz_fce_compile.h_inst('iconst_5')                 := cz_fce_compile_utils.unsigned_byte (8);
     cz_fce_compile.h_inst('bipush')                   := cz_fce_compile_utils.unsigned_byte (16);
     cz_fce_compile.h_inst('sipush')                   := cz_fce_compile_utils.unsigned_byte (17);
     cz_fce_compile.h_inst('ldc')                      := cz_fce_compile_utils.unsigned_byte (18);
     cz_fce_compile.h_inst('ldc_w')                    := cz_fce_compile_utils.unsigned_byte (19);
     cz_fce_compile.h_inst('aload')                    := cz_fce_compile_utils.unsigned_byte (25);
     cz_fce_compile.h_inst('aload_0')                  := cz_fce_compile_utils.unsigned_byte (42);
     cz_fce_compile.h_inst('aload_1')                  := cz_fce_compile_utils.unsigned_byte (43);
     cz_fce_compile.h_inst('aload_2')                  := cz_fce_compile_utils.unsigned_byte (44);
     cz_fce_compile.h_inst('aload_3')                  := cz_fce_compile_utils.unsigned_byte (45);
     cz_fce_compile.h_inst('aaload')                   := cz_fce_compile_utils.unsigned_byte (50);
     cz_fce_compile.h_inst('astore')                   := cz_fce_compile_utils.unsigned_byte (58);
     cz_fce_compile.h_inst('astore_0')                 := cz_fce_compile_utils.unsigned_byte (75);
     cz_fce_compile.h_inst('astore_1')                 := cz_fce_compile_utils.unsigned_byte (76);
     cz_fce_compile.h_inst('astore_2')                 := cz_fce_compile_utils.unsigned_byte (77);
     cz_fce_compile.h_inst('astore_3')                 := cz_fce_compile_utils.unsigned_byte (78);
     cz_fce_compile.h_inst('aastore')                  := cz_fce_compile_utils.unsigned_byte (83);
     cz_fce_compile.h_inst('pop')                      := cz_fce_compile_utils.unsigned_byte (87);
     cz_fce_compile.h_inst('mpop')                     := cz_fce_compile_utils.unsigned_byte (88);
     cz_fce_compile.h_inst('dup')                      := cz_fce_compile_utils.unsigned_byte (89);
     cz_fce_compile.h_inst('swap')                     := cz_fce_compile_utils.unsigned_byte (95);
     cz_fce_compile.h_inst('ret')                      := cz_fce_compile_utils.unsigned_byte (169);
     cz_fce_compile.h_inst('areturn')                  := cz_fce_compile_utils.unsigned_byte (176);
     cz_fce_compile.h_inst('invokevirtual')            := cz_fce_compile_utils.unsigned_byte (182);
     cz_fce_compile.h_inst('invokestatic')             := cz_fce_compile_utils.unsigned_byte (184);
     cz_fce_compile.h_inst('newarray')                 := cz_fce_compile_utils.unsigned_byte (188);
     cz_fce_compile.h_inst('multinewarray')            := cz_fce_compile_utils.unsigned_byte (202);
     cz_fce_compile.h_inst('haload_0')                 := cz_fce_compile_utils.unsigned_byte (203);
     cz_fce_compile.h_inst('hastore_0')                := cz_fce_compile_utils.unsigned_byte (204);
     cz_fce_compile.h_inst('bulkaastore')              := cz_fce_compile_utils.unsigned_byte (205);
     cz_fce_compile.h_inst('pushtrue')                 := cz_fce_compile_utils.unsigned_byte (206);
     cz_fce_compile.h_inst('pushfalse')                := cz_fce_compile_utils.unsigned_byte (207);
     cz_fce_compile.h_inst('pushmath')                 := cz_fce_compile_utils.unsigned_byte (208);
     cz_fce_compile.h_inst('haload_1')                 := cz_fce_compile_utils.unsigned_byte (209);
     cz_fce_compile.h_inst('hastore_1')                := cz_fce_compile_utils.unsigned_byte (210);
     cz_fce_compile.h_inst('haload_2')                 := cz_fce_compile_utils.unsigned_byte (211);
     cz_fce_compile.h_inst('copyto')                   := cz_fce_compile_utils.unsigned_byte (212);
     cz_fce_compile.h_inst('copyto_0')                 := cz_fce_compile_utils.unsigned_byte (213);
     cz_fce_compile.h_inst('copyto_1')                 := cz_fce_compile_utils.unsigned_byte (214);
     cz_fce_compile.h_inst('copyto_2')                 := cz_fce_compile_utils.unsigned_byte (215);
     cz_fce_compile.h_inst('copyto_3')                 := cz_fce_compile_utils.unsigned_byte (216);
     cz_fce_compile.h_inst('aload_w')                  := cz_fce_compile_utils.unsigned_byte (217);
     cz_fce_compile.h_inst('astore_w')                 := cz_fce_compile_utils.unsigned_byte (218);
     cz_fce_compile.h_inst('copyto_w')                 := cz_fce_compile_utils.unsigned_byte (219);
     cz_fce_compile.h_inst('comment')                  := cz_fce_compile_utils.unsigned_byte (220);

     cz_fce_compile.h_methoddescriptors('Solver.createModelDef(String)') := 1;
     cz_fce_compile.h_methoddescriptors('IModelDef.intVar(String, int, int)') := 2;
     cz_fce_compile.h_methoddescriptors('IModelDef.logicVar(String)') := 3;
     cz_fce_compile.h_methoddescriptors('IModelDef.floatVar(String, double, double)') := 5;
     cz_fce_compile.h_methoddescriptors('IModelDef.bagVar(String, Object[], int, int, int, int, int)') := 6;
     cz_fce_compile.h_methoddescriptors('IModelDef.setVar(String, Object[], int, int)') := 7;
     cz_fce_compile.h_methoddescriptors('IModelDef.singletonVar(String, IModelDef)') := 8;
     cz_fce_compile.h_methoddescriptors('IModelDef.instanceSetVar(String, IModelDef, int, int)') := 9;
     cz_fce_compile.h_methoddescriptors('IModelDef.instanceVar(String, IModelDef)') := 10;
     cz_fce_compile.h_methoddescriptors('IModelDef.connectorSetVar(String, IModelDef, int, int)') := 11;
     cz_fce_compile.h_methoddescriptors('Solver.createBomModelDef(String, boolean)') := 12;
     cz_fce_compile.h_methoddescriptors('IModelDef.bomModelVar(String, IBomModelDef, boolean, double, double, double, int, int, Date, Date, long)') := 13;
     cz_fce_compile.h_methoddescriptors('IModelDef.bomModelVar(String, IBomModelDef, boolean, int, int, int, int, int, Date, Date, long)') := 14;
     cz_fce_compile.h_methoddescriptors('Solver.createBomOCDef(String, boolean)') := 15;
     cz_fce_compile.h_methoddescriptors('IBomDef.bomOptionClassVar(String, IBomOCDef, boolean, double, double, double, int, int, Date, Date, long)') := 16;
     cz_fce_compile.h_methoddescriptors('IBomDef.bomOptionClassVar(String, IBomOCDef, boolean, int, int, int, int, int, Date, Date, long)') := 17;
     cz_fce_compile.h_methoddescriptors('IBomDef.bomStandardItemVar(String, boolean, double, double, double, Date, Date, long)') := 18;
     cz_fce_compile.h_methoddescriptors('IBomDef.bomStandardItemVar(String, boolean, int, int, int, Date, Date, long)') := 19;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.setDomOrderMinFirst()') := 20;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.setDomOrderMaxFirst()') := 21;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.setDomOrderDecMax()') := 22;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.setDomOrderIncMin()') := 23;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.setReversePort(IPortExprDef)') := 24;
     cz_fce_compile.h_methoddescriptors('IModelDef.addConstraint(ILogicExprDef)') := 25;
     cz_fce_compile.h_methoddescriptors('IModelDef.addConstraint(IForAllDef)') := 26;
     cz_fce_compile.h_methoddescriptors('IModelDef.addDefaultDecision(ILogicExprDef)') := 27;
     cz_fce_compile.h_methoddescriptors('IModelDef.addDefaultDecision(IForAllDef)') := 28;
     cz_fce_compile.h_methoddescriptors('IModelDef.addSearchDecision(ILogicExprDef)') := 29;
     cz_fce_compile.h_methoddescriptors('IModelDef.addSearchDecision(IForAllDef)') := 30;
     cz_fce_compile.h_methoddescriptors('INumExprDef.sum(INumExprDef)') := 31;
     cz_fce_compile.h_methoddescriptors('INumExprDef.diff(INumExprDef)') := 32;
     cz_fce_compile.h_methoddescriptors('INumExprDef.prod(INumExprDef)') := 33;
     cz_fce_compile.h_methoddescriptors('INumExprDef.ceil()') := 34;
     cz_fce_compile.h_methoddescriptors('INumExprDef.floor()') := 35;
     cz_fce_compile.h_methoddescriptors('INumExprDef.round()') := 36;
     cz_fce_compile.h_methoddescriptors('INumExprDef.div(INumExprDef)') := 37;
     cz_fce_compile.h_methoddescriptors('INumExprDef.eq(INumExprDef)') := 38;
     cz_fce_compile.h_methoddescriptors('INumExprDef.neq(INumExprDef)') := 39;
     cz_fce_compile.h_methoddescriptors('INumExprDef.gt(INumExprDef)') := 40;
     cz_fce_compile.h_methoddescriptors('INumExprDef.lt(INumExprDef)') := 41;
     cz_fce_compile.h_methoddescriptors('INumExprDef.ge(INumExprDef)') := 42;
     cz_fce_compile.h_methoddescriptors('INumExprDef.le(INumExprDef)') := 43;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.equiv(ILogicExprDef)') := 44;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.implies(ILogicExprDef)') := 45;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.excludes(ILogicExprDef)') := 46;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.notequiv(ILogicExprDef)') := 47;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.and(ILogicExprDef)') := 48;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.or(ILogicExprDef)') := 49;
     cz_fce_compile.h_methoddescriptors('INumExprDef.trunc()') := 50;
     cz_fce_compile.h_methoddescriptors('INumExprDef.pow(int)') := 51;
     cz_fce_compile.h_methoddescriptors('INumExprDef.log()') := 52;
     cz_fce_compile.h_methoddescriptors('INumExprDef.exp()') := 53;
     cz_fce_compile.h_methoddescriptors('INumExprDef.abs()') := 54;
     cz_fce_compile.h_methoddescriptors('INumExprDef.sqrt()') := 55;
     cz_fce_compile.h_methoddescriptors('INumExprDef.cos()') := 56;
     cz_fce_compile.h_methoddescriptors('INumExprDef.acos()') := 57;
     cz_fce_compile.h_methoddescriptors('INumExprDef.asin()') := 58;
     cz_fce_compile.h_methoddescriptors('INumExprDef.atan()') := 59;
     cz_fce_compile.h_methoddescriptors('IExprDef.assign()') := 60;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.minFirst()') := 61;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.maxFirst()') := 62;
     cz_fce_compile.h_methoddescriptors('INumExprDef.incMin()') := 63;
     cz_fce_compile.h_methoddescriptors('INumExprDef.decMax()') := 64;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.not()') := 65;
     cz_fce_compile.h_methoddescriptors('IModelDef.any(ILogicExprDef[])') := 66;
     cz_fce_compile.h_methoddescriptors('IModelDef.all(ILogicExprDef[])') := 67;
     cz_fce_compile.h_methoddescriptors('IModelDef.min(INumExprDef[])') := 68;
     cz_fce_compile.h_methoddescriptors('IModelDef.max(INumExprDef[])') := 69;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.card()') := 70;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.card()') := 71;
     cz_fce_compile.h_methoddescriptors('IModelDef.literal(int)') := 72;
     cz_fce_compile.h_methoddescriptors('IModelDef.literal(double)') := 73;
     cz_fce_compile.h_methoddescriptors('INumExprDef.sum(int)') := 74;
     cz_fce_compile.h_methoddescriptors('INumExprDef.diff(int)') := 75;
     cz_fce_compile.h_methoddescriptors('INumExprDef.prod(int)') := 76;
     cz_fce_compile.h_methoddescriptors('INumExprDef.div(int)') := 77;
     cz_fce_compile.h_methoddescriptors('INumExprDef.eq(int)') := 78;
     cz_fce_compile.h_methoddescriptors('INumExprDef.neq(int)') := 79;
     cz_fce_compile.h_methoddescriptors('INumExprDef.gt(int)') := 80;
     cz_fce_compile.h_methoddescriptors('INumExprDef.lt(int)') := 81;
     cz_fce_compile.h_methoddescriptors('INumExprDef.ge(int)') := 82;
     cz_fce_compile.h_methoddescriptors('INumExprDef.le(int)') := 83;
     cz_fce_compile.h_methoddescriptors('INumExprDef.sum(double)') := 84;
     cz_fce_compile.h_methoddescriptors('INumExprDef.diff(double)') := 85;
     cz_fce_compile.h_methoddescriptors('INumExprDef.prod(double)') := 86;
     cz_fce_compile.h_methoddescriptors('INumExprDef.div(double)') := 87;
     cz_fce_compile.h_methoddescriptors('INumExprDef.eq(double)') := 88;
     cz_fce_compile.h_methoddescriptors('INumExprDef.neq(double)') := 89;
     cz_fce_compile.h_methoddescriptors('INumExprDef.gt(double)') := 90;
     cz_fce_compile.h_methoddescriptors('INumExprDef.lt(double)') := 91;
     cz_fce_compile.h_methoddescriptors('INumExprDef.ge(double)') := 92;
     cz_fce_compile.h_methoddescriptors('INumExprDef.le(double)') := 93;
     cz_fce_compile.h_methoddescriptors('IExprDef.setId(long)') := 94;
     cz_fce_compile.h_methoddescriptors('IModelDef.getVar(String)') := 95;
     cz_fce_compile.h_methoddescriptors('IInstanceQuantifier.getType()') := 96;
     cz_fce_compile.h_methoddescriptors('ISingletonExprDef.getType()') := 97;
     cz_fce_compile.h_methoddescriptors('ISingletonExprDef.getVarRef(IExprDef)') := 98;
     cz_fce_compile.h_methoddescriptors('IInstanceQuantifier.getExprFromInstance(IExprDef)') := 99;
     cz_fce_compile.h_methoddescriptors('IModelDef.instancesOf(IPortExprDef)') := 100;
     cz_fce_compile.h_methoddescriptors('IInstanceQuantifier.instancesOf(IPortExprDef)') := 101;
     cz_fce_compile.h_methoddescriptors('IModelDef.forAll(IInstanceQuantifier, ILogicExprDef)') := 102;
     cz_fce_compile.h_methoddescriptors('IModelDef.forAll(IInstanceQuantifier, IInstanceQuantifier, ILogicExprDef)') := 103;
     cz_fce_compile.h_methoddescriptors('IModelDef.forAll(IInstanceQuantifier[], ILogicExprDef)') := 104;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.getMin()') := 105;
     cz_fce_compile.h_methoddescriptors('IIntExprDef.getMax()') := 106;
     cz_fce_compile.h_methoddescriptors('IBomDef.absQty()') := 107;
     cz_fce_compile.h_methoddescriptors('IBomDef.relQty()') := 108;
     cz_fce_compile.h_methoddescriptors('IBomDef.selected()') := 109;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.contains(Object)') := 110;
     cz_fce_compile.h_methoddescriptors('IModelDef.literal(boolean)') := 111;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.equiv(boolean)') := 112;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.implies(boolean)') := 113;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.excludes(boolean)') := 114;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.notequiv(boolean)') := 115;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.and(boolean)') := 116;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.or(boolean)') := 117;
     cz_fce_compile.h_methoddescriptors('IModelDef.sum(INumExprDef[])') := 118;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.hierarchicalUnion(IPortExprDef)') := 119;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.sum(INumExprDef)') := 120;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.getType()') := 121;
     cz_fce_compile.h_methoddescriptors('INumExprDef.neg()') := 122;
     cz_fce_compile.h_methoddescriptors('IBagExprDef.elementCount(Object)') := 123;
     cz_fce_compile.h_methoddescriptors('IModelDef.compat(Object[], Object[][])') := 124;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.intersects(Object[])') := 125;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.getCardMin()') := 126;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.getCardMax()') := 127;
     cz_fce_compile.h_methoddescriptors('IBomDef.getOCCardSet()') := 128;
     cz_fce_compile.h_methoddescriptors('IModelDef.addDefaultDecision(IDecisionExprDef)') := 129;
     cz_fce_compile.h_methoddescriptors('IModelDef.addSearchDecision(IDecisionExprDef)') := 130;
     cz_fce_compile.h_methoddescriptors('IBagExprDef.count()') := 131;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.elementCount(Object)') := 132;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.subsetEq(IPortExprDef)') := 133;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.union(IPortExprDef)') := 134;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveFrom(Date)') := 135;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveUntil(Date)') := 136;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveUsages(long)') := 137;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.setEffectiveFrom(Date)') := 138;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.setEffectiveUntil(Date)') := 139;
     cz_fce_compile.h_methoddescriptors('ISetExprDef.setEffectiveUsages(long)') := 140;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.setEffectiveFrom(Date)') := 141;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.setEffectiveUntil(Date)') := 142;
     cz_fce_compile.h_methoddescriptors('IPortExprDef.setEffectiveUsages(long)') := 143;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveFrom(Date)') := 144;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveUntil(Date)') := 145;
     cz_fce_compile.h_methoddescriptors('ILogicExprDef.setEffectiveUsages(long)') := 146;
     cz_fce_compile.h_methoddescriptors('IDecisionDef.setEffectiveFrom(Date)') := 147;
     cz_fce_compile.h_methoddescriptors('IDecisionDef.setEffectiveUntil(Date)') := 148;
     cz_fce_compile.h_methoddescriptors('IDecisionDef.setEffectiveUsages(long)') := 149;

     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('add')) := 'INumExprDef.sum(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('subtract')) := 'INumExprDef.diff(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('multiply')) := 'INumExprDef.prod(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('div')) := 'INumExprDef.div(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('equals')) := 'INumExprDef.eq(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('notequals')) := 'INumExprDef.neq(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('gt')) := 'INumExprDef.gt(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('lt')) := 'INumExprDef.lt(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('ge')) := 'INumExprDef.ge(INumExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('le')) := 'INumExprDef.le(INumExprDef)';

     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('add')) := 'INumExprDef.sum(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('subtract')) := 'INumExprDef.diff(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('multiply')) := 'INumExprDef.prod(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('div')) := 'INumExprDef.div(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('equals')) := 'INumExprDef.eq(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('notequals')) := 'INumExprDef.neq(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('gt')) := 'INumExprDef.gt(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('lt')) := 'INumExprDef.lt(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('ge')) := 'INumExprDef.ge(int)';
     cz_fce_compile.h_operators_2_int ( cz_fce_compile.h_templates('le')) := 'INumExprDef.le(int)';

     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('add')) := 'INumExprDef.sum(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('subtract')) := 'INumExprDef.diff(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('multiply')) := 'INumExprDef.prod(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('div')) := 'INumExprDef.div(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('equals')) := 'INumExprDef.eq(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('notequals')) := 'INumExprDef.neq(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('gt')) := 'INumExprDef.gt(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('lt')) := 'INumExprDef.lt(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('ge')) := 'INumExprDef.ge(double)';
     cz_fce_compile.h_operators_2_double ( cz_fce_compile.h_templates('le')) := 'INumExprDef.le(double)';

     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('requires')) := 'ILogicExprDef.equiv(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('implies')) := 'ILogicExprDef.implies(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('excludes')) := 'ILogicExprDef.excludes(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('negates')) := 'ILogicExprDef.notequiv(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('and')) := 'ILogicExprDef.and(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('or')) := 'ILogicExprDef.or(ILogicExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('subsetof')) := 'IPortExprDef.subsetEq(IPortExprDef)';
     cz_fce_compile.h_operators_2 ( cz_fce_compile.h_templates('union')) := 'IPortExprDef.union(IPortExprDef)';

     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('requires')) := 'ILogicExprDef.equiv(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('implies')) := 'ILogicExprDef.implies(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('excludes')) := 'ILogicExprDef.excludes(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('negates')) := 'ILogicExprDef.notequiv(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('and')) := 'ILogicExprDef.and(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('or')) := 'ILogicExprDef.or(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('equals')) := 'ILogicExprDef.equiv(boolean)';
     cz_fce_compile.h_operators_2_boolean ( cz_fce_compile.h_templates('notequals')) := 'ILogicExprDef.notequiv(boolean)';

     --These operators are only allowed to be used in the Where clause of a Forall or with Selection()
     --for text properties. In all cases Compiler evaluates such expressions at compile time, and
     --there is no corresponding Solver methods.

     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('doesnotbeginwith')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('doesnotendwith')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('doesnotcontain')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('notlike')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('concatenate')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('beginswith')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('endswith')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('contains')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('like')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('matches')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('textequals')) := NULL;
     cz_fce_compile.h_operators_2_text ( cz_fce_compile.h_templates ('textnotequals')) := NULL;

     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('truncate')) := 'INumExprDef.trunc()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('ceiling')) := 'INumExprDef.ceil()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('floor')) := 'INumExprDef.floor()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('round')) := 'INumExprDef.round()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('ln')) := 'INumExprDef.log()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('exp')) := 'INumExprDef.exp()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('abs')) := 'INumExprDef.abs()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('neg')) := 'INumExprDef.neg()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('sqrt')) := 'INumExprDef.sqrt()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('cos')) := 'INumExprDef.cos()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('acos')) := 'INumExprDef.acos()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('asin')) := 'INumExprDef.asin()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('atan')) := 'INumExprDef.atan()';
     cz_fce_compile.h_operators_1 ( cz_fce_compile.h_templates('not')) := 'ILogicExprDef.not()';

     cz_fce_compile.h_operators_3 ( cz_fce_compile.h_templates('anytrue')) := 'IModelDef.any(ILogicExprDef[])';
     cz_fce_compile.h_operators_3 ( cz_fce_compile.h_templates('alltrue')) := 'IModelDef.all(ILogicExprDef[])';
     cz_fce_compile.h_operators_3 ( cz_fce_compile.h_templates('min')) := 'IModelDef.min(INumExprDef[])';
     cz_fce_compile.h_operators_3 ( cz_fce_compile.h_templates('max')) := 'IModelDef.max(INumExprDef[])';

     cz_fce_compile.h_operators_3_opt ( cz_fce_compile.h_templates('anytrue')) := 'ILogicExprDef.or(ILogicExprDef)';
     cz_fce_compile.h_operators_3_opt ( cz_fce_compile.h_templates('alltrue')) := 'ILogicExprDef.and(ILogicExprDef)';

     cz_fce_compile.h_heuristic_ops ( cz_fce_compile.h_templates('assign')) := 'IExprDef.assign()';
     cz_fce_compile.h_heuristic_ops ( cz_fce_compile.h_templates('minfirst')) := 'IIntExprDef.minFirst()';
     cz_fce_compile.h_heuristic_ops ( cz_fce_compile.h_templates('maxfirst')) := 'IIntExprDef.maxFirst()';
     cz_fce_compile.h_heuristic_ops ( cz_fce_compile.h_templates('incmin')) := 'INumExprDef.incMin()';
     cz_fce_compile.h_heuristic_ops ( cz_fce_compile.h_templates('decmax')) := 'INumExprDef.decMax()';

     cz_fce_compile.h_mathrounding_ops ( cz_fce_compile.h_templates('mod')) := 'INumExprDef.floor()';
     cz_fce_compile.h_mathrounding_ops ( cz_fce_compile.h_templates('roundtonearest')) := 'INumExprDef.round()';
     cz_fce_compile.h_mathrounding_ops ( cz_fce_compile.h_templates('rounddowntonearest')) := 'INumExprDef.floor()';
     cz_fce_compile.h_mathrounding_ops ( cz_fce_compile.h_templates('rounduptonearest')) := 'INumExprDef.ceil()';

     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('anytrue')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('alltrue')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('requires')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('implies')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('excludes')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('negates')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('and')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('or')) := 1;
     cz_fce_compile.h_logical_ops ( cz_fce_compile.h_templates('not')) := 1;

     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('equals')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('notequals')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('min')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('max')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('gt')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('lt')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('ge')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('le')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('add')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('subtract')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('neg')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('multiply')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('ceiling')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('floor')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('round')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('div')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('pow')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('integerpow')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('ln')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('exp')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('abs')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('sqrt')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('cos')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('acos')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('asin')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('atan')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('addsto')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('subtractsfrom')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('log')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('cosh')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('sin')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('sinh')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('tan')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('tanh')) := 1;
     cz_fce_compile.h_numeric_ops ( cz_fce_compile.h_templates('aggregatesum')) := 1;

     --These operators are allowed as rounding operators in a simple accumulation template.

     cz_fce_compile.h_rounding_ops ( cz_fce_compile.h_templates('truncate')) := 1;
     cz_fce_compile.h_rounding_ops ( cz_fce_compile.h_templates('ceiling')) := 1;
     cz_fce_compile.h_rounding_ops ( cz_fce_compile.h_templates('floor')) := 1;
     cz_fce_compile.h_rounding_ops ( cz_fce_compile.h_templates('round')) := 1;
     cz_fce_compile.h_rounding_ops ( cz_fce_compile.h_templates('none')) := 1;

     --These operators are allowed as accumulation operators in a simple accumulation template.

     cz_fce_compile.h_accumulation_ops ( cz_fce_compile.h_templates('addsto')) := 1;
     cz_fce_compile.h_accumulation_ops ( cz_fce_compile.h_templates('subtractsfrom')) := 1;

     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('log')) := 1;
     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('cosh')) := 1;
     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('sin')) := 1;
     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('sinh')) := 1;
     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('tan')) := 1;
     cz_fce_compile.h_trigonometric_ops ( cz_fce_compile.h_templates('tanh')) := 1;

     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('equals'))        := '=';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('notequals'))     := '<>';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('gt'))            := '>';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('lt'))            := '<';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('ge'))            := '>=';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('le'))            := '<=';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('and'))           := 'AND';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('or'))            := 'OR';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('not'))           := 'NOT';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('add'))           := '+';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('subtract'))      := '-';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('multiply'))      := '*';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('div'))           := '/';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('totext'))        := 'TO_CHAR';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('neg'))           := '-';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('textequals'))    := '=';
     cz_fce_compile.h_template_tokens ( cz_fce_compile.h_templates('textnotequals')) := '<>';

     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('quantity')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('state')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('value')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('instancecount')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('integervalue')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('decimalvalue')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('decimalquantity')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('relativequantity')) := 1;
     cz_fce_compile.h_runtime_properties ( cz_fce_compile.h_templates('relativedecquantity')) := 1;

     --These tables contain methods that should be called for bom case. If a property is not
     --applicable for bom, the value does not matter.

     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('quantity')) := 'IBomDef.absQty()';
     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('decimalquantity')) := 'IBomDef.absQty()';
     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('relativequantity')) := 'IBomDef.relQty()';
     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('relativedecquantity')) := 'IBomDef.relQty()';
     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('assignquantity')) := 'IBomDef.absQty()';
     cz_fce_compile.h_quantities ( cz_fce_compile.h_templates('assigndecquantity')) := 'IBomDef.absQty()';

END populate_fce_data;
---------------------------------------------------------------------------------------
END;

/
