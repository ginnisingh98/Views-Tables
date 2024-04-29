--------------------------------------------------------
--  DDL for Package XLA_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_FLEX_UTIL" AUTHID CURRENT_USER AS
/* $Header: xlauflex.pkh 120.1 2004/02/13 22:55:09 weshen noship $ */

   -- Record type to store flexfield segment Number and segment order number
   TYPE r_segmentInfo IS RECORD (segment_num      NUMBER,
    				 segment_ordernum NUMBER
    				 );
   TYPE t_segmentInfo IS TABLE OF r_segmentinfo INDEX BY BINARY_INTEGER ;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    getsegmentInfo                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets accounting flexfield segment number and segment order number      |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  p_chartofAccountsID                                     |
 |              OUT: p_segmentInfo                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-May-2000  Shishir Joshi     Created                                |
 |                                                                           |
 +===========================================================================*/
FUNCTION getsegmentInfo(p_chartofaccountsid IN  NUMBER,
                        p_segmentinfo       OUT NOCOPY t_segmentInfo
			) RETURN BOOLEAN;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_account_flex_info                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets accounting flexfield information based on the chart of accounts id|
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    xla_debug.print                                                        |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id        -- E.g 222 for Receivables      |
 |                   p_account_type          -- Valid account type internal  |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-Oct-98  Mahesh Sabapathy    Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_account_flex_info (
		p_chart_of_accounts_id    IN     NUMBER,
                x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2);

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_ordered_account                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    return the account ordered by balancing segment, natural account and   |
 |    all other segments						     |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  p_charts_of_accounts_id                                 |
 |                   p_table_alias                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-Nov-98  Dirk Stevens        Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_ordered_account(
		p_chart_of_accounts_id IN NUMBER
	       ,p_table_alias          IN VARCHAR2 )
RETURN VARCHAR2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    is_segment_dependent                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    returns 'Y' if the segment is dependent                                |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  segment                                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     15-Apr-98  Dirk Stevens        Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION is_segment_dependent(segment              IN NUMBER
                              ,p_ChartOfAccountsID IN NUMBER
                              ,p_flex_code         IN VARCHAR2
                              ,p_applicationID     IN NUMBER)
  RETURN VARCHAR2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_parent_segment                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns parent segment number and application column name for a        |
 |    given child segment number and structure id.                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS    							     |
 |              p_application_id      IN  NUMBER,		             |
 |              p_flex_code           IN  VARCHAR2                           |
 |              p_structure_id        IN  NUMBER                             |
 |              p_child_segment_num   IN  NUMBER                             |
 |              p_parent_segment_num  OUT NOCOPY NUMBER                             |
 |              p_parent_col_name     OUT NOCOPY VARCHAR                            |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-Aug-99  Shishir Joshi    Created                                   |
 |                                                                           |
 +===========================================================================*/


 PROCEDURE get_parent_segment(p_application_id      IN  NUMBER
			      ,p_flex_code          IN  VARCHAR2
			      ,p_structure_id       IN  NUMBER
			      ,p_child_segment_num  IN  NUMBER
			      ,p_parent_segment_num OUT NOCOPY NUMBER
			      ,p_parent_col_name    OUT NOCOPY VARCHAR2);

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_segment_number                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns segment number for a given chart of accounts and qualifier.    |
 |    This function was added because fnd_flex_apis does not have an api     |
 |    to return the segment number for a qualifier.                          |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS    							     |
 |              p_application_id      IN  NUMBER,		             |
 |              p_flex_code           IN  VARCHAR2                           |
 |              p_structure_id        IN  NUMBER                             |
 |              p_flex_qual_name      IN  VARCHAR2                           |
 |              p_seg_num             OUT NOCOPY NUMBER                             |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-May-00  Dimple Shah    Created                                     |
 |                                                                           |
 +===========================================================================*/


 FUNCTION get_segment_number(p_application_id      IN  NUMBER,
                             p_flex_code           IN  VARCHAR2,
                             p_structure_id        IN  NUMBER,
                             p_flex_qual_name      IN  VARCHAR2,
                             p_seg_num             OUT NOCOPY NUMBER)
 RETURN BOOLEAN;

END XLA_FLEX_UTIL;

 

/
