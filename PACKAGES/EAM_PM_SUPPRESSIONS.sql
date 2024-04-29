--------------------------------------------------------
--  DDL for Package EAM_PM_SUPPRESSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_SUPPRESSIONS" AUTHID CURRENT_USER AS
/* $Header: EAMPSUPS.pls 115.3 2003/08/26 01:31:39 aan ship $ */

    G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_PM_SUPPRESSIONS';



  /**
   * This function is used to check whether a loop will be formed by adding a new
   * suppression relation as specified by the given parameters.
   * This should be called before the record is actually inserted into the table.
   */
  function check_no_loop(p_parent_assoc_id in number,
                         p_child_assoc_id  in number) return boolean;

  /**
   * This procedure is used to check whether the suppression relationship rule is
   * broken or not by adding one more suppression relation. The rule is that one
   * can suppress many, but one can only be suppressed by one.
   * This should be called before the record is actually inserted into the table.
   */
  function is_supp_rule_maintained(p_parent_assoc_id in number,
                                   p_child_assoc_id  in number) return boolean;

  /* This method instantiates all suppression templates defined on the asset group
  including the description. */

  PROCEDURE instantiate_suppressions(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,
	p_maintenance_object_id		IN 		NUMBER
);

  procedure instantiate_suppression(
    p_parent_association_id IN NUMBER,
    p_child_association_id IN NUMBER,
    p_maintenance_object_id IN NUMBER);

END eam_pm_suppressions;


 

/
