--------------------------------------------------------
--  DDL for Package PN_CAD_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_CAD_IMPORT" AUTHID CURRENT_USER AS
  -- $Header: PNVLOSPS.pls 120.2 2005/08/04 22:51:43 appldev ship $

  PROCEDURE import_cad (
    errbuf                  OUT NOCOPY    VARCHAR2,
    retcode                 OUT NOCOPY    VARCHAR2,
    p_batch_name            VARCHAR2,
    function_flag           VARCHAR2,
    p_org_id                NUMBER
  );


  PROCEDURE locations_itf (
    p_batch_name    VARCHAR2,
    p_org_id        NUMBER,
    errbuf          out NOCOPY    varchar2,
    retcode         out NOCOPY    varchar2
  );


  Function  Is_Id_Code_Valid (
     p_Loc_Id   NUMBER ,
     p_Loc_Code Varchar2,
     p_org_id   NUMBER)
  Return Boolean;


  Function  Exists_Property_Id ( p_property_id  NUMBER )
  Return Boolean;


  PROCEDURE space_allocations_itf (
    p_batch_name    VARCHAR2,
    p_org_id        NUMBER,
    errbuf          out NOCOPY    varchar2,
    retcode         out NOCOPY    varchar2
  );

  Procedure Put_Log (p_String VarChar2);
  Procedure Put_Line(p_String VarChar2);

  Function  Get_Location_Type ( p_location_id Number )
  Return    VarChar2;


-------------------
-- End of Pkg
-------------------
END PN_CAD_IMPORT;

 

/
