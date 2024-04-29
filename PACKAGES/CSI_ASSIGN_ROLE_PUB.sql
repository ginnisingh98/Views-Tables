--------------------------------------------------------
--  DDL for Package CSI_ASSIGN_ROLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ASSIGN_ROLE_PUB" AUTHID CURRENT_USER AS
-- $Header: csipupls.pls 120.0 2006/01/10 20:59 epajaril noship $

PROCEDURE ROLE_ASSIGNMENT(
   x_errbuf        OUT nocopy varchar2,
   x_retcode       OUT nocopy number);

END CSI_ASSIGN_ROLE_PUB;

 

/
