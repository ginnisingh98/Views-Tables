--------------------------------------------------------
--  DDL for Package HRBISORGPARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRBISORGPARAMS" AUTHID CURRENT_USER as
/* $Header: hrbistab.pkh 115.2 2002/12/06 14:16:47 cbridge ship $ */

  function GetOrgStructureID
    ( p_org_structure_version_id   IN  Number )
  return Number;

  function GetOrgStructureVersionID
    ( p_organization_structure_id  IN  Number )
  return Number;

  function GetOrgParamID
  return Number;
 -- pragma Restrict_References (GetOrgParamID, WNDS, WNPS);

  function GetOrgParamID
    ( p_organization_structure_id  IN  Number
    , p_organization_id            IN  Number
    , p_organization_process       IN  Varchar2 )
  return Number;
  --pragma Restrict_References (GetOrgParamID, WNDS, WNPS);

  procedure LoadOrgHierarchy
    ( p_organization_structure_id  IN  Number
    , p_organization_id            IN  Number
    , p_organization_process       IN  Varchar2 );

  procedure LoadAllHierarchies;

  procedure LoadAllHierarchies
    ( errbuf                       OUT NOCOPY Varchar2
    , retcode                      OUT NOCOPY Number );

  function OrgInHierarchy
    ( p_org_param_id               IN  Number
    , p_organization_id_group      IN  Number
    , p_organization_id_child      IN  Number )
  return Number;
  pragma restrict_references (OrgInHierarchy, WNDS, WNPS);

end HrBisOrgParams;

 

/
