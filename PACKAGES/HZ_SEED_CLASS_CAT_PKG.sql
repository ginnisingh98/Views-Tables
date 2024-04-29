--------------------------------------------------------
--  DDL for Package HZ_SEED_CLASS_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_SEED_CLASS_CAT_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHSECLS.pls 115.2 2002/04/30 11:26:54 pkm ship   $*/
  PROCEDURE SEED_CLASS_CATEGORY
  (p_class   IN VARCHAR2,
   p_amaf    IN VARCHAR2,
   p_ampf    IN VARCHAR2,
   p_alnof   IN VARCHAR2,
   p_user_id IN NUMBER DEFAULT 0);

  PROCEDURE SEED_CLASS_CATEGORY_USE
  (p_class       IN VARCHAR2,
   p_col_name    IN VARCHAR2,
   p_awc         IN VARCHAR2,
   p_owner_tab   IN VARCHAR2,
   p_user_id     IN NUMBER DEFAULT 0);
END;

 

/
