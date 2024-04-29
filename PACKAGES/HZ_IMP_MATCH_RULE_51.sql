--------------------------------------------------------
--  DDL for Package HZ_IMP_MATCH_RULE_51
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_MATCH_RULE_51" AUTHID CURRENT_USER AS
PROCEDURE tca_join_entities(trap_explosion in varchar2, rows_in_chunk in number,inserted_duplicates out number);
    PROCEDURE pop_parties( 	 
        p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
        p_to_osr                         IN   VARCHAR2,  
        p_batch_mode_flag                  IN VARCHAR2 ); 
 
  PROCEDURE pop_party_sites ( 
   	 p_batch_id IN	NUMBER,  
        p_from_osr                       IN   VARCHAR2, 
  	     p_to_osr                         IN   VARCHAR2,  
        p_batch_mode_flag                  IN VARCHAR2 ); 
        
  PROCEDURE pop_cp (  
   	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
  	     p_to_osr                         IN   VARCHAR2, 
        p_batch_mode_flag                  IN VARCHAR2 ); 
 
  PROCEDURE pop_contacts (  
   	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
  	     p_to_osr                         IN   VARCHAR2, 
        p_batch_mode_flag                  IN VARCHAR2 ); 
 
 PROCEDURE pop_parties_int ( 
    	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
    	 p_to_osr                         IN   VARCHAR2 );
 
 PROCEDURE pop_party_sites_int ( 
    	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
    	 p_to_osr                         IN   VARCHAR2 );
 
 PROCEDURE pop_cp_int ( 
    	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
    	 p_to_osr                         IN   VARCHAR2 );
 
  PROCEDURE pop_contacts_int (  
   	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
  	     p_to_osr                         IN   VARCHAR2 );
 


PROCEDURE interface_tca_join_entities(p_batch_id in number,
          from_osr in varchar2, to_osr in varchar2, p_threshold in number, p_auto_merge_threshold in number);


PROCEDURE interface_join_entities(p_batch_id in number,
          from_osr in varchar2, to_osr in varchar2, p_threshold in number);
END ;

 

/
