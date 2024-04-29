--------------------------------------------------------
--  DDL for Package AK_UPLOAD_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_UPLOAD_GRP" AUTHID CURRENT_USER as
/* $Header: akgulods.pls 120.2 2005/09/15 22:27:08 tshort ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_UPLOAD_GRP';
G_UPDATE_MODE   BOOLEAN;
-- G_NO_CUSTOM_UPDATE is false, update everything
-- G_NO_CUSTOM_UPDATE is true, update non-customized data only
G_NO_CUSTOM_UPDATE	BOOLEAN := FALSE;
G_COMPARE_UPDATE	BOOLEAN;
G_NON_SEED_DATA		BOOLEAN;
G_UPLOAD_DATE		DATE;
G_GEN_DATE		DATE;
G_EXTRACT_OBJ		VARCHAR2(30);

procedure UPLOAD (
p_update_mode    IN   varchar2,
p_return_status  OUT NOCOPY varchar2
);

end AK_UPLOAD_GRP;

 

/
