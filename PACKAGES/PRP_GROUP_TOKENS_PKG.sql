--------------------------------------------------------
--  DDL for Package PRP_GROUP_TOKENS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_GROUP_TOKENS_PKG" AUTHID CURRENT_USER as
/* $Header: PRPTGTKS.pls 115.0 2002/09/23 17:56:44 vpalaiya noship $ */

procedure LOAD_ROW
  (
  p_owner                 IN VARCHAR2,
  p_group_token_id        IN NUMBER,
  p_object_version_number IN NUMBER,
  p_group_id              IN NUMBER,
  p_token_id              IN NUMBER
  );

end PRP_GROUP_TOKENS_PKG;

 

/
