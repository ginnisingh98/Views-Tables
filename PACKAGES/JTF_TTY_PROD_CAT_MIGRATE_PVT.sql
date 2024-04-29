--------------------------------------------------------
--  DDL for Package JTF_TTY_PROD_CAT_MIGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_PROD_CAT_MIGRATE_PVT" AUTHID CURRENT_USER as
/* $Header: jtftrmps.pls 120.0 2005/06/02 18:21:40 appldev noship $ */

/* This procedure calls other procedure(s) to migrate the interest types, primary
   interest codes and secondary interest codes for Opportunity Expected Purchase
   and Lead Expected Purchase in the JTF_TERR_VALUES_ALL table. It also updates
   the JTF_TERR_QUAL_ALL table with new qual_usg_ids */
PROCEDURE Migrate_All( ERRBUF         OUT NOCOPY    VARCHAR2,
                       RETCODE        OUT NOCOPY    VARCHAR2,
                       p_Debug_Flag   IN            VARCHAR2  default 'N');

/* This procedure migrates interest types, primary interest codes and secondary
   interest codes in the JTF_TERR_VALUES_ALL table */
PROCEDURE Migrate_Product_Cat_Terr(p_Qual_Usg_Id     IN NUMBER,
                                   p_Qual_Usg_Id_New IN NUMBER,
                                   p_Debug_Flag      IN VARCHAR2 Default 'N');

/* This procedure migrates interest types in the JTF_TTY_ROLE_PROD_INT table */
PROCEDURE Migrate_Product_Cat_Role(p_Debug_Flag IN VARCHAR2 Default 'N');

END JTF_TTY_PROD_CAT_MIGRATE_PVT;


 

/
