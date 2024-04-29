--------------------------------------------------------
--  DDL for Package OE_UPGRADE_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPGRADE_WF2" AUTHID CURRENT_USER as
/* $Header: OEXIUWUS.pls 120.0 2005/06/01 01:17:34 appldev noship $ */

V_API_ERROR_CODE    number:=0;      /* Globle variable */
V_DUMMY             varchar2(1);    /* Globle variable */
V_ERROR_CODE        number;         /* Globle variable */
V_ERROR_FLAG        varchar2(1);    /* Globle variable */
V_ERROR_LEVEL       number;         /* Globle variable */
V_ERROR_MESSAGE     varchar2(240);   /* Globle variable */

PROCEDURE get_pre_activity
(
  p_action_id          IN	NUMBER,
  p_sequence_id        IN     NUMBER,
v_pre_activity OUT NOCOPY varchar2,

v_pre_result OUT NOCOPY varchar2

);

FUNCTION get_post_activity
(
  p_action_id          IN	NUMBER,
  p_sequence_id        IN     NUMBER
)
return VARCHAR2;

FUNCTION get_instance_id
(
  p_process_name      IN   varchar2,
  p_activity_name     IN   varchar2,
  p_instance_label    IN   varchar2
)
return number;

PROCEDURE insert_into_wf_table
(
  p_from_instance_id  IN   NUMBER,
  p_to_instance_id    IN   NUMBER,
  p_result_code       IN   VARCHAR2,
p_level_error OUT NOCOPY NUMBER

);

PROCEDURE Get_Icon_X_value
(
  p_icon_geometry    IN  varchar2,
p_x_value OUT NOCOPY number

);


PROCEDURE Create_Process_Name
 (
      p_item_type           IN     VARCHAR2,
	 p_line_type           IN     VARCHAR2,
      p_cycle_id            IN     NUMBER
 );

PROCEDURE Create_Lookup_Type
(
     p_item_type   IN   VARCHAR2
);

PROCEDURE Create_Lookup_Code
(
     p_item_type   IN   VARCHAR2
);

PROCEDURE Create_Activity_Name
(
     p_item_type   IN   VARCHAR2
);

PROCEDURE Create_Process_Activity
(
     p_item_type              IN   VARCHAR2,
     p_cycle_id               IN   NUMBER,
     p_line_type              IN   varchar2
);

PROCEDURE Create_Activity_And
(
      p_item_type        IN   varchar2,
      p_line_type        IN   varchar2,
      p_cycle_id         IN   number
);

PROCEDURE Create_Header_Line_Dependency
(
       p_cycle_id          IN    number,
       p_line_type         IN    varchar2
);


PROCEDURE Create_Notification
(
       p_cycle_id          IN     NUMBER,
       p_line_type         IN     VARCHAR2,
       p_item_type         IN     VARCHAR2
);


PROCEDURE Create_Activity_Or
(
     p_item_type         IN     varchar2,
     p_line_type         IN     varchar2,
     p_cycle_id          IN     number
);

PROCEDURE Create_Activity_Transition
(
    p_item_type        IN   varchar2,
    p_cycle_id         IN   number,
    p_line_type        IN   varchar2
);

PROCEDURE Ship_Confirm_Adjusting
(
    p_cycle_id         IN   NUMBER,
    p_line_type        IN   VARCHAR2
);


PROCEDURE ATO_Adjusting
(
    p_cycle_id         IN   NUMBER
);

PROCEDURE Generic_Flow_Adjusting
(
    p_item_type        IN   VARCHAR2,
    p_cycle_id         IN   NUMBER,
    p_line_type        IN   VARCHAR2
);

PROCEDURE Create_Default_Transition
(
      p_item_type         IN    varchar2,
      p_line_type         IN   varchar2,
      p_cycle_id          IN    number
);

PROCEDURE Create_Line_Start
(
      p_cycle_id           IN     number,
      p_line_type          IN     varchar2
);

PROCEDURE Adjust_Arrow_Geometry
(
      p_item_type           IN      varchar2,
      p_line_type           IN      varchar2,
      p_cycle_id            IN      number
);

PROCEDURE Close_Open_End
(
     p_cycle_id            IN     number,
     p_line_type           IN     varchar2,
     p_item_type           IN     varchar2
);


PROCEDURE Upgrade_Workflow;

END OE_UPGRADE_WF2;

 

/
