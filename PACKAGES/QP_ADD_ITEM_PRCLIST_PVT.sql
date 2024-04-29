--------------------------------------------------------
--  DDL for Package QP_ADD_ITEM_PRCLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ADD_ITEM_PRCLIST_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXPRAIS.pls 120.1.12010000.1 2008/07/28 11:55:32 appldev ship $ */

Procedure Get_Conc_Reqvalues
	(x_conc_request_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_program_application_id	OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_program_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_login_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_user_id			OUT NOCOPY /* file.sql.39 change */	NUMBER	);

PROCEDURE Add_Items_To_Price_List
(
 ERRBUF             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 RETCODE            OUT NOCOPY /* file.sql.39 change */  NUMBER,
 p_price_list_id	IN	NUMBER,
 p_start_date_active    IN      DATE,
 p_end_date_active      IN      DATE,
 p_set_price_flag       IN      VARCHAR2,
 p_organization_id	IN	NUMBER,
 p_seg1			IN	VARCHAR2,
 p_seg2			IN	VARCHAR2,
 p_seg3			IN	VARCHAR2,
 p_seg4			IN	VARCHAR2,
 p_seg5			IN	VARCHAR2,
 p_seg6			IN	VARCHAR2,
 p_seg7			IN	VARCHAR2,
 p_seg8			IN	VARCHAR2,
 p_seg9			IN	VARCHAR2,
 p_seg10		IN	VARCHAR2,
 p_seg11		IN	VARCHAR2,
 p_seg12		IN	VARCHAR2,
 p_seg13		IN	VARCHAR2,
 p_seg14		IN	VARCHAR2,
 p_seg15		IN	VARCHAR2,
 p_seg16		IN	VARCHAR2,
 p_seg17		IN	VARCHAR2,
 p_seg18		IN	VARCHAR2,
 p_seg19		IN	VARCHAR2,
 p_seg20		IN	VARCHAR2,
 p_category_id		IN	NUMBER,
 p_status_code		IN	VARCHAR2,
 p_category_set_id      IN      NUMBER,
 p_costorg_id           IN      NUMBER
);
END QP_ADD_ITEM_PRCLIST_PVT;

/
