--------------------------------------------------------
--  DDL for Package ZPB_ECM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_ECM" AUTHID CURRENT_USER AS
/* $Header: zpbecm.pls 120.5 2007/12/04 15:27:01 mbhat ship $ */

type AGGR_ECM is record
   (AggLtRel         varchar2(30),
    AggLtBaseVar     varchar2(30),
    AggLtdRel        varchar2(30),
    AggLtdBaseVar    varchar2(30),
    LdscVar          varchar2(30));

type ALLOC_ECM is record
   (AlcLtRel         varchar2(30),
    AlcLtBaseVar     varchar2(30),
    AlcLtdRel        varchar2(30),
    AlcLtdBaseVar    varchar2(30));

type ANNOT_ECM is record
   (CellsObjDim      varchar2(30),
    CellsShapeRel    varchar2(30),
    CountFrm         varchar2(30),
    DataVar          varchar2(30),
    DateVar          varchar2(30),
    LastDataFrm      varchar2(30),
    LastDateFrm      varchar2(30),
    LastRdscFrm      varchar2(30),
    LastUserFrm      varchar2(30),
    LookupObjDim     varchar2(30),
    LookupShapeRel   varchar2(30),
    ReasonCodeDim    varchar2(30),
    ReasonCodeLdsc   varchar2(30),
    ReasonRel        varchar2(30),
    UserRel          varchar2(30));

type ATTR_ECM is record
   (AttrRelation     varchar2(30),
    DefOrderVSet     varchar2(30),
    LdscVar          varchar2(30),
    LdscFrm          varchar2(30),
    RangeDimension   varchar2(30));

type DIMENSION_DATA is record
   (Ldsc             varchar2(255),
    PlLdsc           varchar2(255),
    PlSdsc           varchar2(150),
    Sdsc             varchar2(150),
    Type             varchar2(30),
    ExpObj           varchar2(30),
    IsDataDim        varchar2(30),
    IsOwnerDim       varchar2(30));

type DIMENSION_ECM is record
   (AncestorRel      varchar2(30),
    AnnDim           varchar2(30),
    DefaultMember    varchar2(40),
    DefOrderVS       varchar2(30),
    DepthFrm         varchar2(30),
    DepthFrm1        varchar2(30),
    DfltLevelRel     varchar2(30),
    DimDrillDir      varchar2(30),
    DrillInfoFrm     varchar2(30),
    FmtCatVar        varchar2(30),
    FmtFlagCatVar    varchar2(30),
    FmtStringVar     varchar2(30),
    FullOrderVar     varchar2(30),
    GID              varchar2(30),
    HierDefault      varchar2(30),
    HierDim          varchar2(30),
    HierDimScpFrm    varchar2(30),
    HierFEMDefIDVar  varchar2(30),
    HierFEMIDVar     varchar2(30),
    HierLdscVar      varchar2(30),
    HierVersLdscVar  varchar2(30),
    HierLevelVS      varchar2(30),
    HierLimitMapVar  varchar2(30),
    HierHeight       varchar2(30),
    HierTypeRel      varchar2(30),
    HOrderVs         varchar2(30),
    InHierVar        varchar2(30),
    LastQueryVS      varchar2(30),
    LdscVar          varchar2(30),
    LevelDepthVar    varchar2(30),
    LevelDim         varchar2(30),
    LevelDimScpFrm   varchar2(30),
    LevelLdscVar     varchar2(30),
    LevelMdscVar     varchar2(30),
    LevelSdscVar     varchar2(30),
    LevelPersVar     varchar2(30),
    LevelPlLdscVar   varchar2(30),
    LevelRel         varchar2(30),
    LimitMapVar      varchar2(30),
    MdscVar          varchar2(30),
    MemberTypeRel    varchar2(30),
    MLevelLdscFrm    varchar2(30),
    MPLLevelLdscFrm  varchar2(30),
    NameFragment     varchar2(30),
    ParentRel        varchar2(30),
    RootValSet       varchar2(30),
    SdscVar          varchar2(30),
    SecOwnAccVar     varchar2(30),
    SecOwnDscVar     varchar2(30),
    SecReadAccFrm    varchar2(30),
    SecReadAccVar    varchar2(30),
    SecWrtAccVar     varchar2(30),
    SibOrderVar      varchar2(30),
    TempVS           varchar2(30));

type DIMENSION_LINE_ECM is record
   (AggBaseFrm       varchar2(30),
    AggDefFrm        varchar2(30),
    AggLdBaseVar     varchar2(30),
    AggLdRel         varchar2(30),
    AggLineBaseVar   varchar2(30),
    AggLineRel       varchar2(30),
    AggOrderVar      varchar2(30),
    AlcBaseFrm       varchar2(30),
    AlcDefBaseVar    varchar2(30),
    AlcDefFrm        varchar2(30),
    AlcLdRel         varchar2(30),
    AlcLineBaseVar   varchar2(30),
    AlcLineRel       varchar2(30),
    BetterWorseVar   varchar2(30),
    CumDataVar       varchar2(30),
    LineDimVar       varchar2(30),
    LineTypeRel      varchar2(30),
    NatSignVar       varchar2(30));

type DIMENSION_TIME_ECM is record
   (CalendarVar      varchar2(30),
    EndDateVar       varchar2(30),
    LatestRel        varchar2(30),
    LatestProcRel    varchar2(30),
    OffsetVar        varchar2(30),
    PriorFrm         varchar2(30),
    RangeRel         varchar2(30),
    RangeLvlRel      varchar2(30),
    ROffsetVar       varchar2(30),
    TimeSpanVar      varchar2(30),
    TLvlTypeRel      varchar2(30),
    YardStickDim     varchar2(30),
    YrAgoFrm         varchar2(30));

type GLOBAL_ATTR_ECM is record
   (AttrDisplayVar   varchar2(30),
    DomainDimRel     varchar2(30),
    ExpObjVar        varchar2(30),
    ExpTypeDim       varchar2(30),
    ExpTypeRel       varchar2(30),
    LdscVar          varchar2(30),
    NameFragVar      varchar2(30),
    RangeDimRel      varchar2(30),
    TypeDim          varchar2(30),
    TypeRel          varchar2(30));

type GLOBAL_ECM is record
   (ECMLocator       varchar2(60),
    AggTypeDim       varchar2(30),
    AlcCondDim       varchar2(30),
    AlcTypeDim       varchar2(30),
    AnnEntryDim      varchar2(30),
    AnnPropDim       varchar2(30),
    AttrDim          varchar2(30),
    AttrDimScpFrm    varchar2(32),
    DataTypeDim      varchar2(30),
    DimDim           varchar2(30),
    DimTypeRel       varchar2(30),
    ExpObjVar        varchar2(30),
    FmtBoolPropDim   varchar2(30),
    FmtTextPropDim   varchar2(30),
    IsCurrInstVar    varchar2(30),
    IsDataDimFrm     varchar2(30),
    IsDataDimVar     varchar2(30),
    IsMeasDimFrm     varchar2(30),
    IsOwnerDim       varchar2(30),
    LangDim          varchar2(30),
    LastQueryDimsVS  varchar2(30),
    LdscVar          varchar2(30),
    LineTypeDim      varchar2(30),
    MeasColVar       varchar2(30),
    MeasDimVar       varchar2(30),
    MeasExpObjVar    varchar2(30),
    MeasShapeRel     varchar2(30),
    MeasTypeRel      varchar2(30),
    MeasViewDim      varchar2(30),
    MeasViewRel      varchar2(30),
    NumAttrFrm       varchar2(30),
    NumHierFrm       varchar2(30),
    NumLevelFrm      varchar2(30),
    PlLdscVar        varchar2(30),
    PlSdscVar        varchar2(30),
    SdscVar          varchar2(30),
    SecEntityDim     varchar2(30),
    SecOwnerDim      varchar2(30),
    SecOwnerMapRel   varchar2(30),
    SecScopeFrm      varchar2(30),
    SecUserDim       varchar2(30),
    SecWrtAccFrm     varchar2(30),
    SecWrtMapVar     varchar2(30),
    ShapeDimVS       varchar2(30),
    ShapeEntryDim    varchar2(30),
    TLvlTypeDim      varchar2(30));

type LINE_TYPE_ECM is record
   (LdscVar          varchar2(30),
    LineTypeCDataVar varchar2(30),
    LTypeBWVar       varchar2(30),
    LTypeNatSignVar  varchar2(30));

type SECURITY_ECM is record
   (SecRInUseFrm     varchar2(30),
    SecRInUseVar     varchar2(30));

function GET_AGGREGATION_ECM (p_aw         in varchar2)
   return AGGR_ECM;

function GET_ALLOCATION_ECM (p_aw         in varchar2)
   return ALLOC_ECM;

function GET_ANNOTATION_ECM (p_aw         in varchar2)
   return ANNOT_ECM;

function GET_ATTR_ECM (p_attr            in varchar2,
                       p_global_attr_ecm in global_attr_ecm,
                       p_aw              in varchar2)
   return ATTR_ECM;

function GET_DIMENSION_DATA (p_dim        in varchar2,
                             p_aw         in varchar2)
   return DIMENSION_DATA;

function GET_DIMENSION_ECM (p_dim        in varchar2,
                            p_aw         in varchar2)
   return DIMENSION_ECM;

function GET_DIMENSION_LINE_ECM (p_dim        in varchar2,
                                 p_aw         in varchar2)
   return DIMENSION_LINE_ECM;

function GET_DIMENSION_TIME_ECM (p_dim        in varchar2,
                                 p_aw         in varchar2)
   return DIMENSION_TIME_ECM;

function GET_GLOBAL_ATTR_ECM (p_aw         in varchar2)
   return GLOBAL_ATTR_ECM;

function GET_GLOBAL_ECM (p_aw in varchar2)
   return GLOBAL_ECM;

function GET_LINE_TYPE_ECM (p_aw         in varchar2)
   return LINE_TYPE_ECM;

function GET_SECURITY_ECM (p_aw         in varchar2)
   return SECURITY_ECM;

procedure TEST;

end ZPB_ECM;

/
