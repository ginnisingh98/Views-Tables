--------------------------------------------------------
--  DDL for Package WIP_SFCB_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SFCB_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wipsfcbs.pls 120.0.12010000.2 2008/12/15 10:08:53 adasa ship $ */

/* Public Procedures  */

  PROCEDURE Populate_Efficiency
		       (p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
			p_date_from	    IN  DATE,
			p_date_to	    IN  DATE,
                        p_department_id     IN  NUMBER,
			p_resource_id       IN  NUMBER,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg 	    OUT NOCOPY VARCHAR2 );


  PROCEDURE Populate_Utilization
                       (p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
			p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2);



  PROCEDURE Populate_Productivity (
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2);

  PROCEDURE Populate_Resource_Load (
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2);

  PROCEDURE Resource_Txn (
                        p_DEPARTMENT_ID         IN      NUMBER,
                        p_EMPLOYEE_ID           IN      NUMBER,
                        p_EMPLOYEE_NUM          IN      NUMBER,
                        p_LINE_ID               IN      NUMBER,
                        p_OPERATION_SEQ_NUM     IN      NUMBER,
                        p_ORGANIZATION_ID       IN      NUMBER,
                        p_PRIMARY_QUANTITY      IN      NUMBER,
                        p_PROJECT_ID            IN      NUMBER,
                        p_REASON_ID             IN      NUMBER,
                        p_REFERENCE             IN      VARCHAR2,
                        p_RESOURCE_ID           IN      NUMBER,
                        p_RESOURCE_SEQ_NUM      IN      NUMBER,
                        p_REPETITIVE_SCHEDULE_ID IN     NUMBER,
                        p_SOURCE_CODE           IN      VARCHAR2,
                        p_TASK_ID               IN      NUMBER,
                        p_TRANSACTION_DATE      IN      DATE,
                        p_TRANSACTION_QUANTITY  IN      NUMBER,
                        p_WIP_ENTITY_ID         IN      NUMBER,
                        p_ACCT_PERIOD_ID        IN      NUMBER  DEFAULT NULL,
                        p_ACTIVITY_ID           IN      NUMBER  DEFAULT NULL,
                        p_ACTIVITY_NAME         IN      VARCHAR2  DEFAULT NULL,
                        p_ACTUAL_RESOURCE_RATE  IN      NUMBER        DEFAULT NULL,
                        p_CREATED_BY            IN      NUMBER DEFAULT NULL,
                        p_CREATED_BY_NAME       IN      VARCHAR2 DEFAULT NULL,
                        p_LAST_UPDATED_BY       IN      NUMBER,
                        p_LAST_UPDATED_BY_NAME  IN      VARCHAR2 DEFAULT NULL,
                        p_LAST_UPDATE_DATE      IN      DATE    DEFAULT NULL,
                        p_LAST_UPDATE_LOGIN     IN      NUMBER,
                        p_ATTRIBUTE1            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE10           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE11           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE12           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE13           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE14           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE15           IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE2            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE3            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE4            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE5            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE6            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE7            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE8            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE9            IN      VARCHAR2 DEFAULT NULL,
                        p_ATTRIBUTE_CATEGORY    IN      VARCHAR2 DEFAULT NULL,
                        p_AUTOCHARGE_TYPE       IN      NUMBER  DEFAULT NULL,
                        p_BASIS_TYPE            IN      NUMBER  DEFAULT NULL,
                        p_COMPLETION_TRANSACTION_ID IN  NUMBER DEFAULT NULL,
                        p_CREATION_DATE         IN      DATE    DEFAULT NULL,
                        p_CURRENCY_ACTUAL_RSC_RATE IN NUMBER DEFAULT NULL,
                        p_CURRENCY_CODE         IN      VARCHAR2 DEFAULT NULL,
                        p_CURRENCY_CONVERSION_DATE IN   DATE DEFAULT NULL,
                        p_CURRENCY_CONVERSION_RATE IN   NUMBER DEFAULT NULL,
                        p_CURRENCY_CONVERSION_TYPE IN   VARCHAR2 DEFAULT NULL,
                        p_DEPARTMENT_CODE       IN      VARCHAR2 DEFAULT NULL,
                        p_ENTITY_TYPE           IN      NUMBER  DEFAULT NULL,
                        p_GROUP_ID              IN      NUMBER  DEFAULT NULL,
                        p_LINE_CODE             IN      VARCHAR2 DEFAULT NULL,
                        p_MOVE_TRANSACTION_ID   IN      NUMBER  DEFAULT NULL,
                        p_ORGANIZATION_CODE     IN      VARCHAR2 DEFAULT NULL,
                        p_PO_HEADER_ID          IN      NUMBER  DEFAULT NULL,
                        p_PO_LINE_ID            IN      NUMBER  DEFAULT NULL,
                        p_PRIMARY_ITEM_ID       IN      NUMBER  DEFAULT NULL,
                        p_PRIMARY_UOM           IN      VARCHAR2 DEFAULT NULL,
                        p_PRIMARY_UOM_CLASS     IN      VARCHAR2 DEFAULT NULL,
                        p_PROCESS_PHASE         IN      NUMBER  DEFAULT NULL,
                        p_PROCESS_STATUS        IN      NUMBER  DEFAULT NULL,
                        p_PROGRAM_APPLICATION_ID IN     NUMBER  DEFAULT NULL,
                        p_PROGRAM_ID            IN      NUMBER  DEFAULT NULL,
                        p_PROGRAM_UPDATE_DATE   IN      DATE    DEFAULT NULL,
                        p_RCV_TRANSACTION_ID    IN      NUMBER  DEFAULT NULL,
                        p_REASON_NAME           IN      VARCHAR2 DEFAULT NULL,
                        p_RECEIVING_ACCOUNT_ID  IN      NUMBER DEFAULT NULL,
                        p_REQUEST_ID            IN      NUMBER DEFAULT NULL,
                        p_RESOURCE_CODE         IN      VARCHAR2 DEFAULT NULL,
                        p_RESOURCE_TYPE         IN      NUMBER DEFAULT NULL,
                        p_SOURCE_LINE_ID        IN      NUMBER  DEFAULT NULL,
                        p_STANDARD_RATE_FLAG    IN      NUMBER  DEFAULT NULL,
                        p_TRANSACTION_ID        IN      NUMBER DEFAULT NULL,
                        p_TRANSACTION_TYPE      IN      NUMBER  DEFAULT NULL,
                        p_TRANSACTION_UOM       IN      VARCHAR2 DEFAULT NULL,
                        p_USAGE_RATE_OR_AMOUNT  IN      NUMBER  DEFAULT NULL,
                        p_WIP_ENTITY_NAME       IN      VARCHAR2 DEFAULT NULL,
		        p_ret_status            OUT NOCOPY     VARCHAR2
                ) ;



   PROCEDURE Populate_Line_Load (
		p_group_id  IN  NUMBER,
		p_date_from IN	DATE,
		p_date_to   IN  DATE,
		p_line_id   IN  NUMBER,
		p_userid    IN  NUMBER,
		p_applicationid IN NUMBER,
		p_errnum    OUT NOCOPY NUMBER,
		p_errmesg   OUT NOCOPY VARCHAR2);




   PROCEDURE Update_Line_Operation (
			p_line_operation IN NUMBER,
			p_wip_entity_id  IN NUMBER,
			p_organization_id IN NUMBER );



   PROCEDURE set_Organization(p_org_id IN NUMBER);
   PROCEDURE set_Linearity_Dates(
			p_from_date IN DATE DEFAULT NULL,
			p_to_date   IN DATE DEFAULT NULL );
   PROCEDURE set_Line( p_line_id IN NUMBER) ;

   FUNCTION get_Organization RETURN NUMBER;
   FUNCTION get_Linearity_From_Date RETURN DATE ;
   FUNCTION get_Linearity_To_Date RETURN DATE ;
   FUNCTION get_Line RETURN NUMBER ;

   --
   -- Determines whether a schedule still needs to perform
   -- the specified line operation.
   --
   -- Returns 1 if p_line_op could come after p_current_line_op in the
   -- specified routing. If p_current_line_op is null, returns 1 if p_line_op
   -- is in the routing. Returns 2 otherwise.
   --
   FUNCTION line_op_is_pending (
				p_line_op in number,
				p_rtg_seq_id in number,
				p_assy_item_id IN NUMBER,
				p_org_id IN NUMBER,
				p_alt_rtg_designator IN VARCHAR2,
				p_current_line_op in NUMBER DEFAULT NULL
   ) RETURN NUMBER ;

  PROCEDURE Populate_Line_Resource_Load (
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
			p_line_id	    IN  NUMBER,
                        p_line_op_id        IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2);

  FUNCTION Get_Workday_Factor
                       (p_sched_start_date      IN  DATE,
                        p_sched_completion_date IN  DATE,
                        p_date_from             IN  DATE,
                        p_date_to               IN  DATE,
                        p_resource_id           IN  NUMBER,
                        p_organization_id       IN  NUMBER )
                        RETURN NUMBER ;

  -- Wrapper function for getting all line operations.  Makes a call to the
  -- bom_rtg_network_api, and returns all line operations from the PL/SQL table
  -- into a deliminated string, so that we can use the values in Java.
  FUNCTION get_all_line_ops (
				  p_rtg_sequence_id	IN 	NUMBER,
                                  p_assy_item_id      IN  NUMBER,
                                  p_org_id            IN  NUMBER,
                                  p_alt_rtg_desig     IN  VARCHAR2 )
                                  RETURN VARCHAR2 ;

  -- Wrapper function to return whether we are at the last line op or not.
  -- Will return 1 if true, 2 if false.  This is needed since we cannot retrieve
  -- boolean values in Java from PL/SQL calls.  Makes a call to function in
  -- bom_rtg_network_api.
  FUNCTION check_last_line_op (
			       p_rtg_sequence_id   IN  NUMBER,
			       p_assy_item_id      IN  NUMBER,
			       p_org_id            IN  NUMBER,
			       p_alt_rtg_desig     IN  VARCHAR2,
			       p_curr_line_op      IN  NUMBER )
                               RETURN NUMBER ;


  /* Pragmas to restrict the references of the various functions */

   PRAGMA RESTRICT_REFERENCES(get_Workday_Factor, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES(get_Organization, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES(get_Linearity_From_Date, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES(get_Linearity_To_Date, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES(get_Line, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES(line_op_is_pending, WNDS);

  /* these api are added to support oracle timezone in the workstation */
  function displaydate_to_displayDT(p_displaydate IN VARCHAR2) return VARCHAR2;
  function displaydate_to_date_tz(p_displaydate IN VARCHAR2) return DATE;
  function displaydt_to_date_tz(p_displaydt IN VARCHAR2) return DATE;

  function date_to_displaydate_tz(p_date IN DATE) return VARCHAR2;
  function date_to_displaydt_tz(p_date IN DATE) return VARCHAR2;

  function is_validate_displaydate(p_date IN VARCHAR2) return VARCHAR2;
  function is_validate_displayDT(p_date IN VARCHAR2) return VARCHAR2;

  function sdate_to_cdate(p_sdate IN DATE) return DATE;
  function cdate_to_sdate(p_cdate IN DATE) return DATE;

  function calculate_dt_range(p_from_dt IN VARCHAR2,
                              p_to_dt IN VARCHAR2) return VARCHAR2;

  procedure init_timezone(p_output_mask IN VARCHAR2, p_outputdt_mask IN VARCHAR2);

  procedure check_attachment_and_contract(p_pkey1 in VARCHAR2,
                                          p_pkey2 in VARCHAR2,
                                          p_pkey3 in VARCHAR2,
                                          p_jobID in number,
                                          x_hasAttachement out nocopy VARCHAR2,
                                          x_hasContract    out nocopy VARCHAR2);


END WIP_SFCB_UTILITIES;

/
