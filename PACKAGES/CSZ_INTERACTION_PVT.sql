--------------------------------------------------------
--  DDL for Package CSZ_INTERACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSZ_INTERACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: cszvints.pls 120.0 2005/06/01 12:21:24 appldev noship $ */



     /*------------------------------------------------------*/
     /* procedure name: begin_interaction                    */
     /* description :  Creates a new interaction interaction */
     /*                record                                */
     /*------------------------------------------------------*/
     PROCEDURE begin_interaction
     (
       p_incident_id      IN  NUMBER,
       p_cust_party_id    IN  NUMBER,
       p_resp_appl_id     IN  NUMBER,
       p_resp_id          IN  NUMBER,
       p_user_id          IN  NUMBER,
       p_login_id         IN  NUMBER,
       p_direction        IN  VARCHAR2,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY  NUMBER,

       x_msg_data         OUT NOCOPY VARCHAR2,
       x_interaction_id   OUT NOCOPY NUMBER,
       x_creation_time    OUT NOCOPY DATE
     );

     /*------------------------------------------------------*/
     /* procedure name: end_interaction                      */
     /* description :  Ends an  interaction record           */
     /*------------------------------------------------------*/
    PROCEDURE end_interaction
     (
       p_interaction_id           IN   NUMBER,
       p_event                    IN   VARCHAR2,
       p_cust_party_id            IN   NUMBER,
       p_resp_appl_id             IN   NUMBER,
       p_resp_id                  IN   NUMBER,
       p_user_id                  IN   NUMBER,
       p_login_Id                 IN   NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2
     );


END;

 

/
