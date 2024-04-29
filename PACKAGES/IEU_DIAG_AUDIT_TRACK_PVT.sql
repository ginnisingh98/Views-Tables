--------------------------------------------------------
--  DDL for Package IEU_DIAG_AUDIT_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_DIAG_AUDIT_TRACK_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUATRS.pls 115.3 2004/05/07 18:02:53 dolee noship $ */
PROCEDURE getDisSpe ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_user_name  IN varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST
                        );
PROCEDURE getUnDis ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST
                        );
PROCEDURE getReDis ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_group_name IN varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_REQUEUED_NST
                        );

PROCEDURE getRequeued ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_REQUEUED_NST
                        );
PROCEDURE getDistributing ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_group_name IN varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST
                        );

 PROCEDURE getNotMember ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE,
                        p_to_date   IN DATE,
                        x_groups  OUT NOCOPY IEU_DIAG_GROUP_NST,
                        x_results OUT NOCOPY IEU_DIAG_NOTMEMBER_NST
                        );



PROCEDURE getLifeCycle(x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_object_code   IN VARCHAR2,
                               p_item_number IN Varchar2,
                               x_results OUT NOCOPY IEU_DIAG_WORKLIFE_NST
                              );


END IEU_DIAG_AUDIT_TRACK_PVT;


 

/
