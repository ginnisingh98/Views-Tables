--------------------------------------------------------
--  DDL for Package WIP_REPETITIVE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REPETITIVE_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wipreuts.pls 115.8 2002/11/29 15:29:22 rmahidha ship $ */

/*============================================================================
SPLIT_SCHEDULE
This procedure split a schedule into two consecutive schedules.
A new schedule is created and the new schedule id is returned.

PARAMETERS
p_sched_id	Id of the schedule to be split
p_org_id	Organization Id
p_new_sched_id	Id of the new schedule that was split from the old schedule

ASUMMPTION
Schedule is released.
=============================================================================*/

PROCEDURE split_schedule
		  (p_sched_id      IN NUMBER,
                   p_org_id        IN NUMBER,
		   p_new_sched_id  IN OUT NOCOPY NUMBER);


/*============================================================================
ROLL_FORWARD
This schedule will release the next schedule defined for a
production line/assembly association if one is defined.
If the p_update_status parameter is TRUE, it will change the status of the
closed schedule to Complete-No Charges if there is a defined schedule or
Complete-Charges if there isn't a schedule defined.

PARAMETERS
p_closed_sched_id	Id of schedule to be closed
p_rollfwd_sched_id   	Id of schedule being roll forward
p_rollfwd_type 		Type of roll forward being done
			includes
				WIP_CONSTANTS.ROLL_COMPLETE
				WIP_CONSTANTS.ROLL_CANCEL
				WIP_CONSTANTS.ROLL_EC_IMP
p_org_id          	Organization Id
p_update_status      	Boolean indicating if status should be updated

=============================================================================*/

PROCEDURE roll_forward
                  (p_closed_sched_id    IN     NUMBER,
                   p_rollfwd_sched_id   IN OUT NOCOPY NUMBER,
                   p_rollfwd_type       IN     NUMBER,
                   p_org_id             IN     NUMBER,
                   p_update_status      IN     BOOLEAN);

PROCEDURE ROLL_FORWARD_COVER
                  (p_closed_sched_id    IN     NUMBER,
                   p_rollfwd_sched_id   IN     NUMBER,
                   p_rollfwd_type       IN     NUMBER,
                   p_org_id             IN     NUMBER,
                   p_update_status      IN     NUMBER,
		   p_success_flag OUT NOCOPY    NUMBER,
		   p_error_msg	 OUT NOCOPY    VARCHAR2);

PROCEDURE get_first_last_sched
	( p_wip_entity_id	IN 	NUMBER,
	  p_org_id		IN	NUMBER,
	  p_line_id		IN 	NUMBER,
	  x_first_sched_id OUT NOCOPY NUMBER,
	  x_last_sched_id  OUT NOCOPY NUMBER,
	  x_error_mesg	 OUT NOCOPY VARCHAR2);

FUNCTION get_line_id
	( p_rep_sched_id	IN	NUMBER,
	  p_org_id		IN	NUMBER) RETURN NUMBER;

END WIP_REPETITIVE_UTILITIES;

 

/
