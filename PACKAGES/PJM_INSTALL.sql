--------------------------------------------------------
--  DDL for Package PJM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_INSTALL" AUTHID CURRENT_USER as
/* $Header: PJMINSTS.pls 120.0 2005/05/24 18:23:33 appldev noship $ */

function CHECK_INSTALL return boolean;

function ENABLE_INSTALL return boolean;

function CHECK_IMPLEMENTATION_STATUS
( P_Organization_ID  NUMBER DEFAULT NULL
) return boolean;

procedure maintain_locator_valuesets;

end PJM_INSTALL;

 

/
