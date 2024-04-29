--------------------------------------------------------
--  DDL for Package OE_BLANKET_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_WF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUBWFS.pls 120.0.12000000.1 2007/01/16 22:01:25 appldev ship $ */

Procedure Create_and_Start_Flow ( p_header_id                IN NUMBER,
                                  p_transaction_phase_code   IN VARCHAR2,
                                  p_blanket_number           IN NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_msg_count                OUT NOCOPY NUMBER,
                                  x_msg_data                 OUT NOCOPY VARCHAR2);

Procedure Submit_draft ( p_header_id                IN NUMBER,
                         p_transaction_phase_code   IN VARCHAR2,
                         x_return_status            OUT NOCOPY VARCHAR2,
                         x_msg_count                OUT NOCOPY NUMBER,
                         x_msg_data                 OUT NOCOPY VARCHAR2);

Procedure Blanket_Date_Changed ( p_header_id                IN NUMBER,
                                 x_return_status            OUT NOCOPY VARCHAR2);

Procedure Customer_acceptance  ( p_header_id                IN NUMBER,
                                 x_return_status            OUT NOCOPY VARCHAR2,
                                 x_msg_count                OUT NOCOPY NUMBER,
                                 x_msg_data                 OUT NOCOPY VARCHAR2);

Procedure Customer_Rejected(p_header_id           IN NUMBER,
                            p_entity_code         IN VARCHAR2,
                            p_version_number      IN NUMBER,
                            p_reason_type         IN VARCHAR2,
                            p_reason_code         IN VARCHAR2,
                            p_reason_comments     IN VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);

Procedure check_release(p_blanket_number IN NUMBER,
                x_return_status  OUT NOCOPY VARCHAR2);

Procedure Extend(p_header_id     IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2);

Procedure Close(p_header_id      IN NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2);

Procedure Terminate(p_header_id             IN NUMBER,
                    p_terminated_by         IN NUMBER,
                    p_version_number        IN NUMBER,
                    p_reason_type           IN VARCHAR2,
                    p_reason_code           IN VARCHAR2,
                    p_reason_comments       IN VARCHAR2,
                    x_return_status         OUT NOCOPY VARCHAR2,
                    x_msg_count             OUT NOCOPY NUMBER,
                    x_msg_data              OUT NOCOPY VARCHAR2);

Procedure Lost(p_header_id             IN NUMBER,
               p_entity_code           IN VARCHAR2,
               p_version_number        IN NUMBER,
               p_reason_type           IN VARCHAR2,
               p_reason_code           IN VARCHAR2,
               p_reason_comments       IN VARCHAR2,
               x_return_status         OUT NOCOPY VARCHAR2,
               x_msg_count             OUT NOCOPY NUMBER,
               x_msg_data              OUT NOCOPY VARCHAR2);

Procedure Complete_Negotiation(p_header_id             IN NUMBER,
                               x_return_status         OUT NOCOPY VARCHAR2);

end OE_Blanket_wf_util;

 

/
