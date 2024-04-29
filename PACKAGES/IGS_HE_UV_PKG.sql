--------------------------------------------------------
--  DDL for Package IGS_HE_UV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UV_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE18S.pls 120.2 2005/09/29 16:11:06 appldev ship $ */

  PROCEDURE copy_unit_version (
     p_c_old_unit_cd		IN      VARCHAR2
    ,p_n_old_version_number     IN      NUMBER
    ,p_c_new_unit_cd		IN	VARCHAR2
    ,p_n_new_version_number	IN	NUMBER
    ,p_n_status			OUT NOCOPY     NUMBER
    ,p_c_message                OUT NOCOPY     VARCHAR2
    );

END IGS_HE_UV_PKG;

 

/
