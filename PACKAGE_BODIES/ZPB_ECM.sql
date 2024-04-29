--------------------------------------------------------
--  DDL for Package Body ZPB_ECM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_ECM" AS
/* $Header: zpbecm.plb 120.6 2007/12/04 15:26:41 mbhat ship $ */

m_olapSchema varchar2(4) := upper(zpb_aw.get_schema)||'.';

TYPE global_ecm_hash IS TABLE OF GLOBAL_ECM INDEX BY VARCHAR2(30);
m_global_ecm_hash global_ecm_hash;

TYPE dimension_ecm_hash IS TABLE OF DIMENSION_ECM INDEX BY VARCHAR2(60);
m_dim_ecm_hash dimension_ecm_hash;

-------------------------------------------------------------------------------
-- GET_PROP
--
-------------------------------------------------------------------------------
function GET_PROP (p_property   in varchar2,
                   p_object     in varchar2)
   return varchar2
   is
begin
   return zpb_aw.interp('shw obj(property '''||p_property||''' '''||
                        p_object||''')');
end GET_PROP;

-------------------------------------------------------------------------------
-- GET_AGGREGATION_ECM
--
-------------------------------------------------------------------------------
function GET_AGGREGATION_ECM (p_aw         in varchar2)
   return AGGR_ECM is
      l_aw          varchar2(30);
      l_aggrEcm     aggr_ecm;
      l_lineType    varchar2(30);
      l_global_ecm  global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_lineType := l_aw||l_global_ecm.LineTypeDim;

   l_aggrEcm.AggLtRel      := get_prop ('AGGLTREL', l_lineType);
   l_aggrEcm.AggLtBaseVar  := get_prop ('AGGLTBASEVAR', l_lineType);
   l_aggrEcm.AggLtdRel     := get_prop ('AGGLTDREL', l_lineType);
   l_aggrEcm.AggLtdBaseVar := get_prop ('AGGLTDBASEVAR', l_lineType);
   l_aggrEcm.LdscVar       := get_prop ('LDSCVAR',
                                        l_aw||l_global_ecm.AggTypeDim);

   return l_aggrEcm;
end GET_AGGREGATION_ECM;

-------------------------------------------------------------------------------
-- GET_ANNOTATION_ECM
--
-------------------------------------------------------------------------------
function GET_ANNOTATION_ECM (p_aw         in varchar2)
   return ANNOT_ECM is
      l_aw           varchar2(30);
      l_annotEcm     annot_ecm;
      l_annEntry     varchar2(30);
      l_global_ecm   global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_annEntry := l_global_ecm.AnnEntryDim;

   l_annotEcm.CellsObjDim    := get_prop('CELLSOBJDIM', l_annEntry);
   l_annotEcm.CellsShapeRel  := get_prop('CELLSSHAPEREL', l_annEntry);
   l_annotEcm.CountFrm       := get_prop('COUNTFRM', l_annEntry);
   l_annotEcm.DataVar        := get_prop('DATAVAR', l_annEntry);
   l_annotEcm.DateVar        := get_prop('DATEVAR', l_annEntry);
   l_annotEcm.LastDataFrm    := get_prop('LASTDATAFRM', l_annEntry);
   l_annotEcm.LastDateFrm    := get_prop('LASTDATEFRM', l_annEntry);
   l_annotEcm.LastRdscFrm    := get_prop('LASTRDSCFRM', l_annEntry);
   l_annotEcm.LastUserFrm    := get_prop('LASTUSERFRM', l_annEntry);
   l_annotEcm.LookupObjDim   := get_prop('LOOKUPOBJDIM', l_annEntry);
   l_annotEcm.LookupShapeRel := get_prop('LOOKUPSHAPEREL', l_annEntry);
   l_annotEcm.ReasonCodeDim  := get_prop('REASONCODEDIM', l_annEntry);
   l_annotEcm.ReasonCodeLdsc := get_prop('LDSCVAR', l_annotEcm.ReasonCodeDim);
   l_annotEcm.ReasonRel      := get_prop('REASONREL', l_annEntry);
   l_annotEcm.UserRel        := get_prop('USERREL', l_annEntry);

   return l_annotEcm;
end GET_ANNOTATION_ECM;

-------------------------------------------------------------------------------
-- GET_ALLOCATION_ECM
--
-------------------------------------------------------------------------------
function GET_ALLOCATION_ECM (p_aw         in varchar2)
   return ALLOC_ECM is
      l_aw           varchar2(30);
      l_allocEcm     alloc_ecm;
      l_lineType     varchar2(30);
      l_global_ecm   global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_lineType := l_aw||l_global_ecm.LineTypeDim;

   l_allocEcm.AlcLtRel      := get_prop ('ALCLTREL',l_lineType);
   l_allocEcm.AlcLtBaseVar  := get_prop ('ALCLTBASEVAR', l_lineType);
   l_allocEcm.AlcLtdRel     := get_prop ('ALCLTDREL', l_lineType);
   l_allocEcm.AlcLtdBaseVar := get_prop ('ALCLTDBASEVAR', l_lineType);

   return l_allocEcm;
end GET_ALLOCATION_ECM;

-------------------------------------------------------------------------------
-- GET_ATTR_ECM
--
-------------------------------------------------------------------------------
function GET_ATTR_ECM (p_attr            in varchar2,
                       p_global_attr_ecm in global_attr_ecm,
                       p_aw              in varchar2)
   return ATTR_ECM is
      l_attrDim    varchar2(30);
      l_attrEcm    attr_ecm;
      l_aw         varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_attrDim := l_aw||l_global_ecm.AttrDim;
   l_attrEcm.AttrRelation :=
      zpb_aw.interp('shw '||l_aw||p_global_attr_ecm.ExpObjVar|| '(' ||l_aw||
                    l_global_ecm.AttrDim||' '''||p_attr||''')');

   l_attrEcm.LdscFrm := get_prop ('LDSCFRM', l_attrEcm.AttrRelation);

   l_attrDim := l_global_ecm.AttrDim;
   l_attrEcm.RangeDimension :=
      zpb_aw.interp ('shw '||l_aw||p_global_attr_ecm.RangeDimRel|| '('||
                     l_aw||l_global_ecm.AttrDim||' '''||p_attr||''')');

   l_attrEcm.DefOrderVSet := get_prop('DEFORDERVSET',l_attrEcm.RangeDimension);
   l_attrEcm.LdscVar      := get_prop('LDSCVAR',l_attrEcm.RangeDimension);

   return l_attrEcm;
end GET_ATTR_ECM;

-------------------------------------------------------------------------------
-- GET_DIMENSION_DATA
--
-------------------------------------------------------------------------------
function GET_DIMENSION_DATA (p_dim        in varchar2,
                             p_aw         in varchar2)
   return DIMENSION_DATA
   is
      l_dim_data   DIMENSION_DATA;
      l_aw         varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   zpb_aw.execute ('push '||l_aw||l_global_ecm.DimDim);
   zpb_aw.execute ('limit '||l_aw||l_global_ecm.DimDim||' to '''||p_dim||'''');

   l_dim_data.Ldsc   := zpb_aw.interp ('shw '||l_aw||l_global_ecm.LdscVar);
   l_dim_data.PlLdsc := zpb_aw.interp ('shw '||l_aw||l_global_ecm.PlLdscVar);
   l_dim_data.PlSdsc := zpb_aw.interp ('shw '||l_aw||l_global_ecm.PlSdscVar);
   l_dim_data.Sdsc   := zpb_aw.interp ('shw '||l_aw||l_global_ecm.SdscVar);
   l_dim_data.Type   := zpb_aw.interp ('shw '||l_aw||l_global_ecm.DimTypeRel);
   l_dim_data.ExpObj := zpb_aw.interp ('shw '||l_aw||l_global_ecm.ExpObjVar);
   if (zpb_aw.interpbool ('shw '||l_aw||l_global_ecm.IsDataDimVar)) then
      l_dim_data.IsDataDim := 'YES';
    else
      l_dim_data.IsDataDim := 'NO';
   end if;
   if (zpb_aw.interpbool ('shw SHARED!ISOWNERDIM (SHARED!'||
                          l_global_ecm.DimDim||' '''||p_dim||''')')) then
      l_dim_data.IsOwnerDim := 'YES';
    else
      l_dim_data.IsOwnerDim := 'NO';
   end if;

   zpb_aw.execute ('pop '||l_aw||l_global_ecm.DimDim);
   return l_dim_data;

end GET_DIMENSION_DATA;
-------------------------------------------------------------------------------
-- GET_DIMENSION_ECM
--
-- Builds a DIMENSION_ECM object, given the dimension.  The dimension should
-- be the value stored in the DimDim ECM object.  If the ECM data cannot be
-- found, null will be returned.
--
-- IN: p_dim        (varchar2)   - The name of the dimension in DimDim
--     l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw         (varchar2)   - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT:  DIMENSION_ECM
--
-------------------------------------------------------------------------------
function GET_DIMENSION_ECM (p_dim        in varchar2,
                            p_aw         in varchar2)
   return DIMENSION_ECM
   is
      l_dim        varchar2(60);
      l_dim_ecm    DIMENSION_ECM;
      l_aw         varchar2(30);
      l_awQual     varchar2(30);
      l_hierDim    varchar2(30);
      l_levelDim   varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);

   begin
      l_dim_ecm := m_dim_ecm_hash(l_aw||'***'||p_dim);
      return l_dim_ecm;
   exception
      when no_data_found then
         null;
   end;

   l_global_ecm := get_global_ecm(p_aw);
   l_awQual := l_aw||'!';

   l_dim := l_awQual||zpb_aw.interp('shw '||l_awQual||l_global_ecm.ExpObjVar||
                                ' ('||l_awQual||l_global_ecm.DimDim||' '''||
                                p_dim||''')');

   l_dim_ecm.AncestorRel     := get_prop('ANCESTORREL', l_dim);
   l_dim_ecm.AnnDim          := get_prop('ANNDIM', l_dim);
   l_dim_ecm.DefaultMember   := get_prop('DEFAULTMEMBER', l_dim);
   l_dim_ecm.DefOrderVS      := get_prop('DEFORDERVS', l_dim);
   l_dim_ecm.DepthFrm        := get_prop('DEPTHFRM', l_dim);
   l_dim_ecm.DepthFrm1       := get_prop('DEPTHFRM1', l_dim);
   l_dim_ecm.DfltLevelRel    := get_prop('DFLTLEVELREL', l_dim);
   l_dim_ecm.DimDrillDir     := get_prop('DIMDRILLDIR', l_dim);
   l_dim_ecm.DrillInfoFrm    := get_prop('DRILLINFOFRM', l_dim);
   l_dim_ecm.DrillInfoFrm    := get_prop('DRILLINFOFRM', l_dim);
   l_dim_ecm.FmtCatVar       := get_prop('FMTCATVAR', l_dim);
   l_dim_ecm.FmtFlagCatVar   := get_prop('FMTFLAGCATVAR', l_dim);
   l_dim_ecm.FmtStringVar    := get_prop('FMTSTRINGVAR', l_dim);
   l_dim_ecm.FullOrderVar    := get_prop('FULLORDERVAR', l_dim);
   l_dim_ecm.GID             := get_prop('GID', l_dim);
   l_dim_ecm.HierDefault     := get_prop('HIERDEFAULT', l_dim);
   l_dim_ecm.HierDim         := get_prop('HIERDIM', l_dim);
   l_dim_ecm.HierHeight      := get_prop('HIERHEIGHT', l_dim);
   l_dim_ecm.HOrderVs        := get_prop('HORDERVS', l_dim);
   l_dim_ecm.InHierVar       := get_prop('INHIERVAR', l_dim);
   l_dim_ecm.LastQueryVS     := get_prop('LASTQUERYVS', l_dim);
   l_dim_ecm.LdscVar         := get_prop('LDSCVAR', l_dim);
   l_dim_ecm.LevelDim        := get_prop('LEVELDIM', l_dim);
   l_dim_ecm.LevelRel        := get_prop('LEVELREL', l_dim);
   l_dim_ecm.LimitMapVar     := get_prop('LIMITMAPVAR', l_dim);
   l_dim_ecm.MdscVar         := get_prop('MDSCVAR', l_dim);
   l_dim_ecm.MemberTypeRel   := get_prop('MEMBERTYPEREL', l_dim);
   l_dim_ecm.MLevelLdscFrm   := get_prop('MLEVELLDSCFRM', l_dim);
   l_dim_ecm.MPLLevelLdscFrm := get_prop('MPLLEVELLDSCFRM', l_dim);
   l_dim_ecm.NameFragment    := get_prop('NAMEFRAGMENT', l_dim);
   l_dim_ecm.ParentRel       := get_prop('PARENTREL', l_dim);
   l_dim_ecm.RootValSet      := get_prop('ROOTVALSET', l_dim);
   l_dim_ecm.SdscVar         := get_prop('SDSCVAR', l_dim);
   l_dim_ecm.SecOwnAccVar    := get_prop('SECOWNACCVAR', l_dim);
   l_dim_ecm.SecOwnDscVar    := get_prop('SECOWNDSCVAR', l_dim);
   l_dim_ecm.SecReadAccFrm   := get_prop('SECREADACCFRM', l_dim);
   l_dim_ecm.SecReadAccVar   := get_prop('SECREADACCVAR', l_dim);
   l_dim_ecm.SecWrtAccVar    := get_prop('SECWRTACCVAR', l_dim);
   l_dim_ecm.SibOrderVar     := get_prop('SIBORDERVAR', l_dim);
   l_dim_ecm.TempVS          := get_prop('TEMPVS', l_dim);

   if (l_dim_ecm.HierDim <> 'NA') then
      l_hierDim := l_awQual||l_dim_ecm.HierDim;

      l_dim_ecm.HierDimScpFrm  := get_prop('HIERDIMSCPFRM', l_dim);
      l_dim_ecm.HierFEMDefIDVar:= get_prop('FEMDEFIDVAR', l_hierDim);
      l_dim_ecm.HierFEMIDVar   := get_prop('FEMIDVAR', l_hierDim);
      l_dim_ecm.HierLevelVS    := get_prop('HIERLEVELVS', l_hierDim);
      l_dim_ecm.HierLdscVar    := get_prop('LDSCVAR', l_hierDim);
      l_dim_ecm.HierVersLdscVar:= get_prop('VERSLDSCVAR', l_hierDim);
      l_dim_ecm.HierLimitMapVar:= get_prop('LIMITMAPVAR', l_hierDim);
      l_dim_ecm.HierTypeRel    := get_prop('HIERTYPEREL', l_hierDim);
      l_dim_ecm.LevelDepthVar  := get_prop('LEVELDEPTHVAR', l_hierDim);
   end if;
   if (l_dim_ecm.LevelDim <> 'NA') then
      l_levelDim := l_awQual||l_dim_ecm.LevelDim;
      l_dim_ecm.LevelDimScpFrm := get_prop('LEVELDIMSCPFRM', l_dim);
      l_dim_ecm.LevelLdscVar   := get_prop('LDSCVAR', l_levelDim);
      l_dim_ecm.LevelMdscVar   := get_prop('MDSCVAR', l_levelDim);
      l_dim_ecm.LevelSdscVar   := get_prop('SDSCVAR', l_levelDim);
      l_dim_ecm.LevelPersVar   := get_prop('PERSONALVAR', l_levelDim);
      l_dim_ecm.LevelPlLdscVar := get_prop('PLLDSCVAR', l_levelDim);
   end if;
   m_dim_ecm_hash(l_aw||'***'||p_dim) := l_dim_ecm;
   return l_dim_ecm;

end GET_DIMENSION_ECM;

-------------------------------------------------------------------------------
-- GET_DIMENSION_LINE_ECM
--
-- Builds a DIMENSION_LINE_ECM object.
--
-- IN: p_dim (varchar2)          - The Line Dimension
--     l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw (varchar2)           - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT: DIMENSION_LINE_ECM
--
-------------------------------------------------------------------------------
function GET_DIMENSION_LINE_ECM (p_dim        in varchar2,
                                 p_aw         in varchar2)
   return DIMENSION_LINE_ECM
   is
      l_dim        varchar2(60);
      l_line_ecm   dimension_line_ecm;
      l_aw         varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_dim :=l_aw||zpb_aw.interp('shw '||l_aw||l_global_ecm.ExpObjVar||'('||
                               l_aw||l_global_ecm.DimDim||' '''||p_dim||''')');

   l_line_ecm.AggBaseFrm      := get_prop('AGGBASEFRM', l_dim);
   l_line_ecm.AggDefFrm       := get_prop('AGGDEFFRM', l_dim);
   l_line_ecm.AggLdBaseVar    := get_prop('AGGLDBASEVAR', l_dim);
   l_line_ecm.AggLdRel        := get_prop('AGGLDREL', l_dim);
   l_line_ecm.AggLineBaseVar  := get_prop('AGGLINEBASEVAR', l_dim);
   l_line_ecm.AggLineRel      := get_prop('AGGLINEREL', l_dim);
   l_line_ecm.AggOrderVar     := get_prop('AGGORDERVAR', l_dim);
   l_line_ecm.AlcBaseFrm      := get_prop('ALCBASEFRM', l_dim);
   l_line_ecm.AlcDefBaseVar   := get_prop('ALCDEFBASEVAR', l_dim);
   l_line_ecm.AlcDefFrm       := get_prop('ALCDEFFRM', l_dim);
   l_line_ecm.AlcLdRel        := get_prop('ALCLDREL', l_dim);
   l_line_ecm.AlcLineBaseVar  := get_prop('ALCLINEBASEVAR', l_dim);
   l_line_ecm.AlcLineRel      := get_prop('ALCLINEREL', l_dim);
   l_line_ecm.BetterWorseVar  := get_prop('BETTERWORSEVAR', l_dim);
   l_line_ecm.CumDataVar      := get_prop('CUMDATAVAR', l_dim);
   l_line_ecm.LineDimVar      := get_prop('LINEDIMVAR', l_dim);
   l_line_ecm.LineTypeRel     := get_prop('LINETYPEREL', l_dim);
   l_line_ecm.NatSignVar      := get_prop('NATSIGNVAR', l_dim);

   return l_line_ecm;

end GET_DIMENSION_LINE_ECM;

-------------------------------------------------------------------------------
-- GET_DIMENSION_TIME_ECM
--
-- Builds a DIMENSION_TIME_ECM object.
--
-- IN: p_dim (varchar2)          - The Time Dimension
--     l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw (varchar2)           - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT: DIMENSION_TIME_ECM
--
-------------------------------------------------------------------------------
function GET_DIMENSION_TIME_ECM (p_dim        in varchar2,
                                 p_aw         in varchar2)
   return DIMENSION_TIME_ECM
   is
      l_dim        varchar2(60);
      l_time_ecm   dimension_time_ecm;
      l_aw         varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_dim :=l_aw||zpb_aw.interp('shw '||l_aw||l_global_ecm.ExpObjVar||'('||
                               l_aw||l_global_ecm.DimDim||' '''||p_dim||''')');

   l_time_ecm.CalendarVar   := get_prop('CALENDARVAR', l_dim);
   l_time_ecm.EndDateVar    := get_prop('ENDDATEVAR', l_dim);
   l_time_ecm.LatestRel     := get_prop('LATESTREL', l_dim);
   l_time_ecm.LatestProcRel := get_prop('LATESTPROCREL', l_dim);
   l_time_ecm.OffsetVar     := get_prop('OFFSETVAR', l_dim);
   l_time_ecm.PriorFrm      := get_prop('PRIORFRM', l_dim);
   l_time_ecm.RangeRel      := get_prop('RANGEREL', l_dim);
   --
   -- Hardcoded, as it is not in ECM:
   --
   l_time_ecm.RangeLvlRel  := 'RANGELVL.'||get_prop('NAMEFRAGMENT', l_dim);
   l_time_ecm.ROffsetVar   := get_prop('ROFFSETVAR', l_dim);
   l_time_ecm.TimeSpanVar  := get_prop('TIMESPANVAR', l_dim);
   l_time_ecm.TLvlTypeRel  := get_prop('TLVLTYPEREL', l_dim);
   l_time_ecm.YardStickDim := get_prop('YARDSTICKDIM', l_dim);
   l_time_ecm.YrAgoFrm     := get_prop('YRAGOFRM', l_dim);

   return l_time_ecm;

end GET_DIMENSION_TIME_ECM;

-------------------------------------------------------------------------------
-- GET_GLOBAL_ATTR_ECM
--
-- Builds a GLOBAL_ATTR_ECM object.
--
-- IN: l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw (varchar2)           - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT: GLOBAL_ATTR_ECM
--
-------------------------------------------------------------------------------
function GET_GLOBAL_ATTR_ECM (p_aw         in varchar2)
   return GLOBAL_ATTR_ECM is
      l_attrDim    varchar2(30);
      l_attr_ecm   global_attr_ecm;
      l_aw         varchar2(30);
      l_global_ecm global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_attrDim := l_aw||l_global_ecm.AttrDim;

   l_attr_ecm.AttrDisplayVar := get_prop('ATTRDISPLAYVAR', l_attrDim);
   l_attr_ecm.DomainDimRel := get_prop('DOMAINDIMREL', l_attrDim);
   l_attr_ecm.ExpObjVar    := get_prop('EXPOBJVAR', l_attrDim);
   l_attr_ecm.ExpTypeDim   := get_prop('EXPTYPEDIM', l_attrDim);
   l_attr_ecm.ExpTypeRel   := get_prop('EXPTYPEREL', l_attrDim);
   l_attr_ecm.LdscVar      := get_prop('LDSCVAR', l_attrDim);
   l_attr_ecm.NameFragVar  := get_prop('NAMEFRAGVAR', l_attrDim);
   l_attr_ecm.RangeDimRel  := get_prop('RANGEDIMREL', l_attrDim);
   l_attr_ecm.TypeDim      := get_prop('TYPEDIM', l_attrDim);
   l_attr_ecm.TypeRel      := get_prop('TYPEREL', l_attrDim);

   return l_attr_ecm;
end GET_GLOBAL_ATTR_ECM;

-------------------------------------------------------------------------------
-- GET_GLOBAL_ECM
--
-- Builds a GLOBAL_ECM object.  If an ECMLocator cannot be found, or the AW
-- cannot be attached, it will return null.
--
-- IN: p_aw (varchar2) - The aw to pull the info from.  If null, then
--                       the current AW is used.
-- OUT:  GLOBAL_ECM
--
-------------------------------------------------------------------------------
function GET_GLOBAL_ECM (p_aw in varchar2)
   return GLOBAL_ECM
   is
      l_ecm    GLOBAL_ECM;
      l_aw     varchar2(30);
      l_awQual varchar2(30);
      l_meas   varchar2(30);
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);

   begin
      l_ecm := m_global_ecm_hash(l_aw);
      return l_ecm;
   exception
      when no_data_found then
         null;
   end;

   l_awQual := l_aw||'!';

   zpb_aw.execute ('call DB.POP.DMVARS ('''||l_aw||''')');
   l_ecm.ECMLocator := zpb_aw.interp('shw DM.ECMLOCATOR');
   if (l_ecm.ECMLocator = 'NA') then
      l_ecm.ECMLocator := '';
      return null;
   end if;

   l_ecm.AggTypeDim     := get_prop('AGGTYPEDIM', l_ecm.ECMLocator);
   l_ecm.AlcCondDim     := get_prop('ALCCONDDIM', l_ecm.ECMLocator);
   l_ecm.AlcTypeDim     := get_prop('ALCTYPEDIM', l_ecm.ECMLocator);
   l_ecm.AnnEntryDim    := get_prop('ANNENTRYDIM', l_ecm.ECMLocator);
   l_ecm.AnnPropDim     := get_prop('ANNPROPDIM', l_ecm.ECMLocator);
   l_ecm.AttrDim        := get_prop('ATTRDIM', l_ecm.ECMLocator);
   l_ecm.AttrDimScpFrm  := get_prop('ATTRDIMSCPFRM', l_ecm.ECMLocator);
   l_ecm.DataTypeDim    := get_prop('DATATYPEDIM', l_ecm.ECMLocator);
   l_ecm.DimDim         := get_prop('DIMDIM', l_ecm.ECMLocator);
   l_ecm.ShapeEntryDim  := get_prop('SHAPEENTRYDIM', l_ecm.DimDim);
   l_ecm.DimTypeRel     := get_prop('DIMTYPEREL', l_ecm.DimDim);
   l_ecm.ExpObjVar      := get_prop('EXPOBJVAR', l_ecm.DimDim);
   l_ecm.FmtBoolPropDim := get_prop('FMTBOOLPROPDIM', l_ecm.ECMLocator);
   l_ecm.FmtTextPropDim := get_prop('FMTTEXTPROPDIM', l_ecm.ECMLocator);
   l_ecm.IsMeasDimFrm   := get_prop('ISMEASDIMFRM', l_ecm.ECMLocator);

   l_meas := zpb_aw.interp('shw '||l_awQual||l_ecm.ExpObjVar||' ('||l_awQual||
                           l_ecm.DimDim||' lmt ('||l_awQual||l_ecm.DimDim||
                           ' to '||l_awQual||l_ecm.IsMeasDimFrm||' eq yes)');

   l_ecm.IsCurrInstVar  := get_prop('ISCURRINSTVAR', l_meas);
   l_ecm.IsDataDimFrm   := get_prop('ISDATADIMFRM', l_ecm.DimDim);
   l_ecm.IsDataDimVar   := get_prop('ISDATADIMVAR', l_ecm.DimDim);
   l_ecm.IsOwnerDim     := get_prop('ISOWNERDIM', l_ecm.DimDim);
   l_ecm.LangDim        := get_prop('LANGDIM', l_ecm.ECMLocator);
   l_ecm.LastQueryDimsVS:= get_prop('LASTQUERYDIMSVS', l_ecm.DimDim);
   l_ecm.LdscVar        := get_prop('LDSCVAR', l_ecm.DimDim);
   l_ecm.LineTypeDim    := get_prop('LINETYPEDIM', l_ecm.ECMLocator);
   l_ecm.MeasColVar     := get_prop('MEASCOLVAR', l_meas);
   l_ecm.MeasDimVar     := get_prop('MEASDIMVAR', l_meas);
   l_ecm.MeasExpObjVar  := get_prop('EXPOBJVAR', l_meas);
   l_ecm.MeasShapeRel   := get_prop('MEASSHAPEREL', l_ecm.ShapeEntryDim);
   l_ecm.ShapeDimVS     := get_prop('SHAPEDIMVS', l_ecm.ShapeEntryDim);
   l_ecm.MeasTypeRel    := get_prop('MEASTYPEREL', l_meas);
   l_ecm.MeasViewDim    := get_prop('MEASVIEWDIM', l_meas);
   l_ecm.MeasViewRel    := get_prop('MEASVIEWREL', l_ecm.MeasViewDim);
   l_ecm.NumAttrFrm     := get_prop('NUMATTRFRM', l_ecm.DimDim);
   l_ecm.NumHierFrm     := get_prop('NUMHIERFRM', l_ecm.DimDim);
   l_ecm.NumLevelFrm    := get_prop('NUMLEVELFRM', l_ecm.DimDim);
   l_ecm.PlLdscVar      := get_prop('PLLDSCVAR', l_ecm.DimDim);
   l_ecm.PlSdscVar      := get_prop('PLSDSCVAR', l_ecm.DimDim);
   l_ecm.SdscVar        := get_prop('SDSCVAR', l_ecm.DimDim);
   l_ecm.SecentityDim   := get_prop('SECENTITYDIM', l_ecm.ECMLocator);
   l_ecm.SecOwnerDim    := get_prop('SECOWNERDIM', l_ecm.ECMLocator);
   l_ecm.SecOwnerMapRel := get_prop('SECOWNERMAPREL', l_ecm.ECMLocator);
   l_ecm.SecScopeFrm    := get_prop('SECSCOPEFRM', l_ecm.ECMLocator);
   l_ecm.SecUserDim     := get_prop('SECUSERDIM', l_ecm.ECMLocator);
   l_ecm.SecWrtAccFrm   := get_prop('SECWRTACCFRM', l_ecm.ECMLocator);
   l_ecm.SecWrtMapVar   := get_prop('SECWRTMAPVAR', l_ecm.ECMLocator);
   l_ecm.TLvlTypeDim    := get_prop('TLVLTYPEDIM', l_ecm.ECMLocator);

   --
   -- Remove the AW qualifier:
   --
   l_ecm.ECMLocator := substr(l_ecm.ECMLocator,instr(l_ecm.ECMLocator, '!')+1);

   m_global_ecm_hash(l_aw) := l_ecm;

   return l_ecm;
end GET_GLOBAL_ECM;

-------------------------------------------------------------------------------
-- GET_LINE_TYPE_ECN
--
-- Builds a LINE_TYPE_ECM object.
--
-- IN: l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw (varchar2)           - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT: LINE_TYPE_ECM
--
-------------------------------------------------------------------------------
function GET_LINE_TYPE_ECM (p_aw         in varchar2)
   return LINE_TYPE_ECM is
      l_lineType      varchar2(30);
      l_line_type_ecm line_type_ecm;
      l_aw            varchar2(30);
      l_global_ecm    global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_lineType := l_aw||l_global_ecm.LineTypeDim;

   l_line_type_ecm.LdscVar          := get_prop('LDSCVAR', l_lineType);
   l_line_type_ecm.LineTypeCDataVar := get_prop('LINETYPECDATAVAR',l_lineType);
   l_line_type_ecm.LTypeBWVar       := get_prop('LTYPEBWVAR', l_lineType);
   l_line_type_ecm.LTypeNatSignVar  := get_prop('LTYPENATSIGNVAR', l_lineType);

   return l_line_type_ecm;
end GET_LINE_TYPE_ECM;

-------------------------------------------------------------------------------
-- GET_SECURITY_ECM
--
-- Builds a SECURITY_ECM object.
--
-- IN: l_global_ecm (GLOBAL_ECM) - The Global Ecm
--     p_aw (varchar2)           - The aw to pull the info from.  If null, then
--                                 the current AW is used.
-- OUT: SECURITY_ECM
--
-------------------------------------------------------------------------------
function GET_SECURITY_ECM (p_aw         in varchar2)
   return SECURITY_ECM
   is
      l_secEntity    varchar2(30);
      l_security_ecm security_ecm;
      l_aw           varchar2(30);
      l_global_ecm   global_ecm;
begin
   if (instr (p_aw,'.') > 0 or p_aw = 'SHARED' or p_aw = 'PERSONAL') then
      l_aw := p_aw;
    else
      l_aw := m_olapSchema||p_aw;
   end if;
   zpb_aw.execute ('aw attach '||l_aw);
   l_global_ecm := get_global_ecm(p_aw);
   l_aw := l_aw||'!';

   l_secEntity := l_aw||l_global_ecm.SecentityDim;

   l_security_ecm.SecRInUseFrm := get_prop ('SECRINUSEFRM', l_secEntity);
   l_security_ecm.SecRInUseVar := get_prop ('SECRINUSEVAR', l_secEntity);

   return l_security_ecm;

end GET_SECURITY_ECM;

-------------------------------------------------------------------------------
-- TEST - Tests various functions.  Internal/Dev use only
--
-------------------------------------------------------------------------------
procedure TEST
   is
      l_ecm  global_ecm;
      l_decm dimension_ecm;
      l_data dimension_data;
begin
null;
/*   l_ecm := GET_GLOBAL_ECM;

   dbms_output.put_line ('ECM Locator:     '||l_ecm.ECMLocator);
   dbms_output.put_line ('DimDim:          '||l_ecm.DimDim);
   dbms_output.put_line ('ExpObjVar:       '||l_ecm.ExpObjVar);
   dbms_output.put_line ('LdscVar:         '||l_ecm.LdscVar);
   dbms_output.put_line ('PlLdscVar:       '||l_ecm.PlLdscVar);
   dbms_output.put_line ('MdscVar:         '||l_ecm.MdscVar);
   dbms_output.put_line ('SdscVar:         '||l_ecm.SdscVar);
   dbms_output.put_line ('DimTypeRel:      '||l_ecm.DimTypeRel);
   dbms_output.put_line ('IsDataDimFrm:    '||l_ecm.IsDataDimFrm);

   l_decm := GET_DIMENSION_ECM ('D1', l_ecm);
   dbms_output.put_line ('ANCESTORREL:     '||l_decm.AncestorRel);
   dbms_output.put_line ('ANNDIM:          '||l_decm.AnnDim);
   dbms_output.put_line ('DEPTHFRM:        '||l_decm.DepthFrm);
   dbms_output.put_line ('DEPTHFRM1:       '||l_decm.DepthFrm1);
   dbms_output.put_line ('DFLTLEVELREL:    '||l_decm.DfltLevelRel);
   dbms_output.put_line ('DIMDRILLDIR:     '||l_decm.DimDrillDir);
   dbms_output.put_line ('DRILLINFOFRM:    '||l_decm.DrillInfoFrm);
   dbms_output.put_line ('FULLORDERVAR:    '||l_decm.FullOrderVar);
   dbms_output.put_line ('HIERDEFAULT:     '||l_decm.HierDefault);
   dbms_output.put_line ('HIERDIM:         '||l_decm.HierDim);
   dbms_output.put_line ('HORDERVS:        '||l_decm.HOrderVs);
   dbms_output.put_line ('INHIERVAR:       '||l_decm.InHierVar);
   dbms_output.put_line ('LDSCVAR:         '||l_decm.LdscVar);
   dbms_output.put_line ('LEVELDIM:        '||l_decm.LevelDim);
   dbms_output.put_line ('LEVELREL:        '||l_decm.LevelRel);
   dbms_output.put_line ('MDSCVAR:         '||l_decm.MdscVar);
   dbms_output.put_line ('MLEVELLDSCFRM:   '||l_decm.MLevelLdscFrm);
   dbms_output.put_line ('MPLLEVELLDSCFRM: '||l_decm.MPLLevelLdscFrm);
   dbms_output.put_line ('NAMEFRAGMENT:    '||l_decm.NameFragment);
   dbms_output.put_line ('PARENTREL:       '||l_decm.ParentRel);
   dbms_output.put_line ('ROOTVALSET:      '||l_decm.RootValSet);
   dbms_output.put_line ('SDSCVAR:         '||l_decm.SdscVar);
   dbms_output.put_line ('SECREADACCVAR:   '||l_decm.SecReadAccVar);
   dbms_output.put_line ('SIBORDERVAR:     '||l_decm.SibOrderVar);

   l_data := GET_DIMENSION_DATA ('D1', l_ecm);
   dbms_output.put_line ('Ldsc:            '||l_data.Ldsc);
   dbms_output.put_line ('PlLdsc:          '||l_data.PlLdsc);
   dbms_output.put_line ('Mdsc:            '||l_data.Mdsc);
   dbms_output.put_line ('Sdsc:            '||l_data.Sdsc);
   dbms_output.put_line ('Type:            '||l_data.Type);
   dbms_output.put_line ('ExpObj:          '||l_data.ExpObj);
   dbms_output.put_line ('IsDataDim:       '||l_data.IsDataDim);
*/
end TEST;

end ZPB_ECM;

/
