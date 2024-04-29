--------------------------------------------------------
--  DDL for Package FTE_SEL_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_SEL_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: FTESELGS.pls 120.0 2005/05/26 17:48:59 appldev noship $ */

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --
  -- Procedure: Validate_Group
  --
  -- 1) Name should be unique
  -- 2) Start/End dates should not overlap with other assigned groups
  --    for each and every assignee
  --    a) CREATE/COPY : 1 assignee
  --    b) UPDATE      : 1 or more assignee

  PROCEDURE Validate_Group(
                        p_group_id       IN          NUMBER,
                        p_name           IN          VARCHAR2,
                        p_start_date     IN          DATE,
                        p_end_date       IN          DATE,
                        p_assignee_type  IN          VARCHAR2,
                        p_assignee_id    IN          NUMBER,
                        p_mode           IN          VARCHAR2,
                        x_return_status  OUT NOCOPY  VARCHAR2,
                        x_msg_count      OUT NOCOPY  NUMBER,
                        x_msg_data       OUT NOCOPY  VARCHAR2);

  -- Procedure: Copy_Group
  --
  -- 1) Copies all the entities composing the group except for FTE_SEL_RESULTS

  PROCEDURE Copy_Group(p_group_id        IN          NUMBER,
                       x_group_id        OUT NOCOPY  NUMBER,
                       x_return_status   OUT NOCOPY  VARCHAR2,
                       x_msg_count       OUT NOCOPY  NUMBER,
                       x_msg_data        OUT NOCOPY  VARCHAR2);

  --
  -- Procedure: Validate_Shipmethod
  --
  -- 1) Checks whether the shipmethod is valid

  PROCEDURE Validate_Shipmethod(p_carrier_id    IN          NUMBER,
                                p_service_level IN          VARCHAR2,
                                p_mode          IN          VARCHAR2,
                                x_return_status	OUT NOCOPY  VARCHAR2,
                                x_msg_data      OUT NOCOPY  VARCHAR2);

  --
  -- Procedure: Validate_Assignment
  --
  -- 1) Checks whether the group can be assigned to the assignee

  PROCEDURE Validate_Assignment(p_group_name    IN          VARCHAR2,
                                p_assignee_type IN          VARCHAR2,
                                p_assignee_id   IN          NUMBER,
                                x_group_id      OUT NOCOPY  NUMBER,
                                x_return_status	OUT NOCOPY  VARCHAR2,
                                x_msg_count     OUT NOCOPY  NUMBER,
                                x_msg_data      OUT NOCOPY  VARCHAR2);

  --
  -- Procedure: Delete_Results
  --
  -- 1) Delete data from FTE_SEL_RESULTS for Update operation
  --

  PROCEDURE Delete_Results(p_group_id      IN          NUMBER,
                          x_return_status  OUT NOCOPY  VARCHAR2,
                          x_msg_count      OUT NOCOPY  NUMBER,
                          x_msg_data       OUT NOCOPY  VARCHAR2);
  --
  -- Procedure: Save_Results
  --
  -- 1) Insert data into FTE_SEL_RESULTS for Create/Copy/Update operation
  --

  PROCEDURE Save_Results( p_group_id      IN          NUMBER,
                          x_return_status  OUT NOCOPY  VARCHAR2,
                          x_msg_count      OUT NOCOPY  NUMBER,
                          x_msg_data       OUT NOCOPY  VARCHAR2);

  --
  -- Function: Is_Valid_Region
  --
  -- Purpose:  Check if the Rule consists of Regions defined in the current language
  --
  --
  FUNCTION Is_Valid_Region(
                  p_group_id            IN      NUMBER
                ) RETURN VARCHAR2;


END FTE_SEL_GROUPS_PKG;

 

/
