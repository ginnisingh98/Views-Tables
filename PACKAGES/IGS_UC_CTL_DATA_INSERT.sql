--------------------------------------------------------
--  DDL for Package IGS_UC_CTL_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_CTL_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: IGSUC60S.pls 115.3 2003/07/10 07:47:43 rgangara noship $  */

  PROCEDURE proc_cvcontrol_view (
     p_v_report			IN	VARCHAR2
    );

  PROCEDURE proc_uvinstitution_view (
     p_v_report                   IN      VARCHAR2
    );

END IGS_UC_CTL_DATA_INSERT;

 

/
