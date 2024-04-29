--------------------------------------------------------
--  DDL for Package HZ_DQM_SEARCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_SEARCH_UTIL" AUTHID CURRENT_USER AS
/*$Header: ARHDQUTS.pls 120.14 2006/10/05 19:00:07 nsinghai noship $ */
/*#
* Checks the availability of Data Quality Management.
* @rep:scope public
* @rep:product HZ
* @rep:displayname DQM Availability
* @rep:category BUSINESS_ENTITY HZ_PARTY
* @rep:lifecycle active
* @rep:doccd 120hztig.pdf Data Quality Management Availability APIs,
* Oracle Trading Community Architecture Technical Implementation Guide
*/

TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE vcharlist IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

PROCEDURE add_transformation (
        p_tx_val        IN      VARCHAR2,
        p_within        IN      VARCHAR2,
        x_tx_str        IN OUT NOCOPY  VARCHAR2);

PROCEDURE add_filter (
        p_tx_val        IN      VARCHAR2,
        p_within        IN      VARCHAR2,
        x_filter_str    IN OUT NOCOPY  VARCHAR2);

PROCEDURE add_attribute (
        p_tx_str        IN      VARCHAR2,
        p_match_str     IN      VARCHAR2,
        x_contains_str  IN OUT NOCOPY  VARCHAR2);

PROCEDURE add_attribute_with_denorm (
        p_tx_str        IN      VARCHAR2,
        p_match_str     IN      VARCHAR2,
        p_denorm_str    IN      VARCHAR2,
        x_contains_str  IN OUT NOCOPY   VARCHAR2);

PROCEDURE add_search_record (
        p_rec_contains_str      IN      VARCHAR2,
        p_filter_str            IN      VARCHAR2,
        x_contains_str          IN OUT NOCOPY  VARCHAR2);

PROCEDURE remove_matches_not_in_subset (
        p_search_ctx_id         IN      NUMBER,
        p_subset_defn           IN      VARCHAR2
);

FUNCTION is_similar (
    p_src               IN  VARCHAR2,
    p_dest              IN  VARCHAR2,
    p_min_similarity 	IN  NUMBER := 100)
  RETURN NUMBER;

-- This Function tests if the DQM indexes have been created
-- and if they are valid
/*#
 * Checks if interMedia indexes in all Data Quality Management staging tables are
 * created and valid. The function accordingly returns FND_API.G_TRUE or FND_API.G_FALSE.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Is DQM Index Available
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
FUNCTION is_dqm_available
  RETURN VARCHAR2;

/*#
 * Checks if a match rule is available, meaning that the rule is compiled and all its active
 * transformations are staged. The function accordingly returns FND_API.G_TRUE or FND_API.G_FALSE.
 * appropriately.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Is DQM Match Rule Available
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
FUNCTION is_dqm_available (
  p_match_rule_id NUMBER
)
  RETURN VARCHAR2;

FUNCTION is_similar_match(
        p_src                   IN      VARCHAR2,
        p_dest                  IN      VARCHAR2,
        p_min_similarity        IN      VARCHAR2,
        p_attr_idx              IN      NUMBER) RETURN BOOLEAN;

FUNCTION is_match(
        p_src                   IN      VARCHAR2,
        p_dest                  IN      VARCHAR2,
        p_attr_idx              IN      NUMBER) RETURN BOOLEAN;

PROCEDURE new_search;

FUNCTION strtok (
    p_string VARCHAR2 DEFAULT NULL,
    p_numtoks NUMBER DEFAULT NULL,
    p_delim VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2;

FUNCTION ESTIMATED_LENGTH(p_str VARCHAR2) RETURN NUMBER;

PROCEDURE update_word_list (
   p_repl_word VARCHAR2,
   p_word_list_id NUMBER);


PROCEDURE set_num_eval(p_num NUMBER);

FUNCTION get_num_eval RETURN NUMBER;

PROCEDURE set_no_score;
PROCEDURE set_score;

PROCEDURE get_quality_score (
    p_srch_ctx_id IN NUMBER,
    p_match_rule_id IN NUMBER) ;

FUNCTION validate_trans_proc(
     P_PROCEDURE_NAME IN VARCHAR2
     ) return VARCHAR2;

FUNCTION validate_custom_proc(
     P_CUST_PROCEDURE_NAME IN VARCHAR2
     ) return VARCHAR2 ;

END ;

 

/
