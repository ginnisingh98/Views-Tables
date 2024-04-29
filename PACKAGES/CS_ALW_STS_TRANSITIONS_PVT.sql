--------------------------------------------------------
--  DDL for Package CS_ALW_STS_TRANSITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_ALW_STS_TRANSITIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: csvalsts.pls 115.3 2004/01/21 17:23:39 spusegao noship $ */

Procedure Copy_Status_Group(p_statusGroupId  IN VARCHAR2,
                            x_statusGroupId OUT NOCOPY VARCHAR2,
                            x_errorCode     OUT NOCOPY NUMBER,
                            x_errorMessage  OUT NOCOPY VARCHAR2);


Procedure AllowedStatus_StartDate_Valid(p_statusGroupId        IN number,
                                           p_allowed_status_id IN number,
                                           p_new_start_date    IN date,
                                           x_errorCode         OUT NOCOPY number,
                                           x_errorMessage      OUT NOCOPY varchar2,
                                           x_return_code       OUT NOCOPY varchar2);


Procedure AllowedStatus_EndDate_Valid(p_statusGroupId          IN number,
                                           p_allowed_status_id IN number,
                                           p_new_end_date      IN date,
                                           p_incident_status_id IN NUMBER,
                                           x_errorCode         OUT NOCOPY number,
                                           x_errorMessage      OUT NOCOPY varchar2,
                                           x_return_code       OUT NOCOPY varchar2);


Procedure StatusTrans_StartDate_Valid(p_statusGroupId          IN number,
                                      p_from_allowed_status_id IN number,
                                      p_to_allowed_status_id   IN number,
                                      p_new_start_date         IN date,
                                      x_errorCode             OUT NOCOPY number,
                                      x_errorMessage          OUT NOCOPY varchar2,
                                      x_return_code           OUT NOCOPY varchar2);

Procedure StatusTrans_EndDate_Valid(p_statusGroupId          IN number,
                                    p_from_allowed_status_id IN number,
                                    p_to_allowed_status_id   IN number,
                                    p_new_end_date           IN date,
                                    x_errorCode             OUT NOCOPY number,
                                    x_errorMessage          OUT NOCOPY varchar2,
                                    x_return_code           OUT NOCOPY varchar2);

Procedure Set_Transition_Ind(p_statusGroupId IN number);

END CS_ALW_STS_TRANSITIONS_PVT;

 

/
