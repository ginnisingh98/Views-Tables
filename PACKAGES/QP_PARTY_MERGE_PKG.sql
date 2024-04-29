--------------------------------------------------------
--  DDL for Package QP_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: QPXPMRGS.pls 120.1 2005/06/13 02:39:17 appldev  $ */

--GLOBAL Constant holding the package name

G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_PARTY_MERGE_PKG';

/***********************************************************************
   Procedure to Merge those qualifier_attr_value's in QP_QUALIFIERS which
   reference Party_Id or Party_Site_Id. To be called by TCA when Parties
   or Party Sites are merged.
***********************************************************************/

Procedure Merge_Qualifiers(p_entity_name             IN  VARCHAR2,
                           p_from_id                 IN  NUMBER,
                           p_to_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
                           p_from_fk_id              IN  NUMBER,
                           p_to_fk_id                IN  NUMBER,
                           p_parent_entity_name      IN  VARCHAR2,
                           p_batch_id                IN  NUMBER,
                           p_batch_party_id          IN  NUMBER,
                           x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


END QP_PARTY_MERGE_PKG;

 

/
