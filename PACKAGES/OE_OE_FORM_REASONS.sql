--------------------------------------------------------
--  DDL for Package OE_OE_FORM_REASONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_REASONS" AUTHID CURRENT_USER AS
/* $Header: OEXFREAS.pls 120.0 2005/06/01 23:09:01 appldev noship $ */

PROCEDURE Apply_Reason(
                          p_reason_type    IN VARCHAR2
                        , p_reason_code    IN VARCHAR2
                        , p_comments       IN VARCHAR2
                        , p_entity_id      IN NUMBER
                        , p_version_number IN NUMBER
                        , p_entity_code    IN VARCHAR2
                        , x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        , x_msg_count OUT NOCOPY NUMBER
                        , x_msg_data OUT NOCOPY VARCHAR2

                      );


PROCEDURE Submit_Draft(
                          p_header_id      IN NUMBER
                        , x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        , x_msg_count OUT NOCOPY NUMBER
                        , x_msg_data OUT NOCOPY VARCHAR2

                      );

PROCEDURE Populate_Version_Number
                      (
                        x_return_status     OUT NOCOPY VARCHAR2
                      , x_msg_count         OUT NOCOPY NUMBER
                      , x_msg_data          OUT NOCOPY VARCHAR2
                      , p_header_id         IN  NUMBER
                      , p_order_version_number IN NUMBER
                      );

PROCEDURE Get_Reason_Rqd_Info
                      (
                        p_entity_id         IN  NUMBER
                      , p_entity_code       IN VARCHAR2
                      , x_audit_reason_capt OUT NOCOPY /* file.sql.39 change */ BOOLEAN
                      , x_reason            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_comments          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_is_reason_rqd     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_return_status     OUT NOCOPY VARCHAR2
                      , x_msg_count         OUT NOCOPY NUMBER
                      , x_msg_data          OUT NOCOPY VARCHAR2
                      );
END Oe_Oe_Form_Reasons;


 

/
