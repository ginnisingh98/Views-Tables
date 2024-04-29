--------------------------------------------------------
--  DDL for Package IGF_AP_LI_ISIR_IMP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LI_ISIR_IMP_PROC" AUTHID CURRENT_USER AS
/* $Header: IGFAP34S.pls 115.3 2003/12/10 07:35:54 rasahoo noship $ */




      TYPE message_rec IS RECORD
                  (field_name    VARCHAR2(30),
                   msg_text      VARCHAR2(2000));


      TYPE igf_ap_message_table IS TABLE OF message_rec
                               INDEX BY BINARY_INTEGER;


      TYPE igf_ap_meaning_table IS TABLE OF message_rec
                               INDEX BY BINARY_INTEGER;

      TYPE lookup_meaning_tab IS TABLE OF message_rec
                               INDEX BY BINARY_INTEGER;

      lookup_meaning_table lookup_meaning_tab;

      TYPE igf_ap_lookups_table IS TABLE OF VARCHAR2(227)
             INDEX BY BINARY_INTEGER;

      lookups_table   DBMS_UTILITY.uncl_array;


      TYPE igf_ap_lkup_hash_table IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
      lookup_hash_table   igf_ap_lkup_hash_table;

      PROCEDURE put_meaning(list IN VARCHAR2);



      PROCEDURE main ( errbuf         IN OUT NOCOPY VARCHAR2,
                       retcode        IN OUT NOCOPY NUMBER,
                       p_award_year   IN VARCHAR2,
                       p_batch_id     IN NUMBER,
                       p_del_int      IN VARCHAR2,
                       p_cps_import   IN VARCHAR2 DEFAULT NULL) ;




      PROCEDURE put_hash_values(list         IN VARCHAR2,
                                p_award_year IN VARCHAR2);

      FUNCTION  is_lookup_code_exist(p_lookup_code IN VARCHAR2,
                                     p_lookup_type IN VARCHAR2)
                RETURN BOOLEAN;


     PROCEDURE create_base_rec(p_ci_cal_type                    IN VARCHAR2,
                              p_person_id                       IN NUMBER,
                              p_ci_sequence_number              IN NUMBER,
                              p_nslds_match_type                IN VARCHAR2,
                              l_fa_base_id                     OUT NOCOPY NUMBER,
                              p_award_fmly_contribution_type    IN VARCHAR2
                          );
      PROCEDURE  cps_import(errbuf         IN OUT  NOCOPY VARCHAR2,
                            retcode        IN OUT  NOCOPY NUMBER,
                            p_award_year   IN VARCHAR2);

     g_person_print                   VARCHAR2(1);

      FUNCTION Val_Name (l_length IN NUMBER,
                         l_value  IN VARCHAR2
                        ) RETURN BOOLEAN ;

      FUNCTION Val_Char (l_length IN NUMBER,
                         l_value  IN VARCHAR2
                        ) RETURN BOOLEAN;



      FUNCTION Val_Date ( l_value IN  VARCHAR2)
                        RETURN BOOLEAN;


      FUNCTION Val_Date_2(l_value IN VARCHAR2
                         ) RETURN BOOLEAN;



      FUNCTION Val_Email(l_length IN NUMBER,
                          l_value IN VARCHAR2
                        ) RETURN BOOLEAN;


      FUNCTION Val_Input_Rec_type(l_value IN  VARCHAR2
                                 ) RETURN BOOLEAN;



      FUNCTION Val_Int(l_value IN  VARCHAR2
                      ) RETURN BOOLEAN;


      FUNCTION Val_Alpha(l_value IN  VARCHAR2,
                         l_length IN NUMBER
                        ) RETURN BOOLEAN;



      FUNCTION Val_Add(l_length IN NUMBER,
                       l_value  IN VARCHAR2
                      ) RETURN BOOLEAN;

      FUNCTION Val_Num(l_length IN NUMBER,
                       l_value  IN VARCHAR2
                      ) RETURN BOOLEAN;


      FUNCTION Val_Num_NonZero( l_value  IN VARCHAR2,
                                l_length IN NUMBER
                              ) RETURN BOOLEAN;


      FUNCTION Val_Num_1(l_value IN  VARCHAR2)
                       RETURN  BOOLEAN;

      FUNCTION Val_Num_12(l_value IN  VARCHAR2)
                          RETURN BOOLEAN;


      FUNCTION Val_Num_2(l_value IN  VARCHAR2)
                         RETURN BOOLEAN;


      FUNCTION Val_Num_3( l_value IN  VARCHAR2)
                        RETURN BOOLEAN;


      FUNCTION Val_Num_4( l_value IN  VARCHAR2)
                         RETURN BOOLEAN;



      FUNCTION Val_Num_5( l_value IN   VARCHAR2)
                         RETURN BOOLEAN;


      FUNCTION Val_Num_7( l_value IN  VARCHAR2)
                         RETURN BOOLEAN;


      FUNCTION Val_Num_9( l_value IN  VARCHAR2)
                         RETURN BOOLEAN;

      FUNCTION Val_School_Cd(	 l_value IN   VARCHAR2,
                               l_length IN NUMBER
                            ) RETURN BOOLEAN;


      FUNCTION Val_Signed_By(	l_value IN  VARCHAR2)
                            RETURN BOOLEAN;


      FUNCTION Val_SSN(l_value IN  VARCHAR2)
                           RETURN BOOLEAN;
      PROCEDURE is_number (
                               p_number  IN           VARCHAR2 ,
                               ret_num   OUT NOCOPY   NUMBER
                             ) ;






  END IGF_AP_LI_ISIR_IMP_PROC;

 

/
