--------------------------------------------------------
--  DDL for Package OKL_RV_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RV_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRVIS.pls 120.1 2005/07/28 06:33:25 smadhava noship $*/

  -- Residual Value Percentage record definition
  TYPE rv_rec_type IS RECORD
   (ITEM_ID                OKL_ITM_CAT_RV_PRCS.CAT_ID1%TYPE
   ,ORG_ID                 OKL_ITM_CAT_RV_PRCS.CAT_ID2%TYPE
   ,TERM_IN_MONTHS         OKL_ITM_CAT_RV_PRCS.TERM_IN_MONTHS%TYPE
   ,RESIDUAL_VALUE_PERCENT OKL_ITM_CAT_RV_PRCS.RESIDUAL_VALUE_PERCENT%TYPE
   ,START_DATE             OKL_ITM_CAT_RV_PRCS.START_DATE%TYPE
   ,END_DATE               OKL_ITM_CAT_RV_PRCS.END_DATE%TYPE
   ,BATCH_NUMER            NUMBER
   ,STATUS                 VARCHAR2(30)
  );


  TYPE  rv_tbl IS TABLE OF rv_rec_type
    INDEX BY BINARY_INTEGER;

  l_rv_rec      rv_rec_type;

  PROCEDURE purge_record (
                          errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN  VARCHAR2
                         ,p_org_id           IN  NUMBER
                         ,p_status           IN  VARCHAR2
                         );


  PROCEDURE Process_Record (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  VARCHAR2,
                            p_org_id           IN  NUMBER
                           );

  PROCEDURE Check_Input_Record(
                            p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  VARCHAR2,
                            p_org_id           IN  NUMBER,
                            x_total_checked    OUT NOCOPY NUMBER,
                            x_total_failed     OUT NOCOPY NUMBER
                           );


  PROCEDURE Load_Input_Record(
                        p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2,
                        p_batch_number     IN  VARCHAR2,
                        x_total_loaded     OUT NOCOPY NUMBER
                       );


  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        );

  PROCEDURE Update_Interface_Status (p_batch_number    IN  VARCHAR2
                                    ,p_status          IN  VARCHAR2
                                    ,p_item_id         IN  NUMBER
                                    ,p_org_id          IN  NUMBER
                                    ,p_term            IN  NUMBER
                                    ,p_rv_percent      IN  NUMBER
                                    ,p_start_date      IN  date
                                    ,p_end_date        IN  date
                                    ,x_return_status   OUT NOCOPY VARCHAR2);


  PROCEDURE GENERATE_RV (
                          ERRBUF             OUT NOCOPY VARCHAR2
                         ,RETCODE            OUT NOCOPY VARCHAR2
                         ,P_BATCH_NUMBER     IN  VARCHAR2
                         ,P_ORG_ID           IN  NUMBER
                         ,P_SO_ITEMS_ONLY_YN IN  VARCHAR2 -- get only items used in quotes
                         ,P_START_DATE       IN  VARCHAR2
                         ,P_END_DATE         IN  VARCHAR2
                         ,P_TERM_LOWER_RANGE IN  NUMBER  -- MIN 1
                         ,P_TERM_UPPER_RANGE IN  NUMBER
                         ,P_TERM_INTERVAL    IN  NUMBER  -- IN MONTHS
                         ,P_INITIAL_RV       IN  NUMBER  -- MAX 100
                         ,P_DECREMENT_RV_BY  IN  NUMBER  -- MIN 1
                         );

  PROCEDURE GENERATE_RESIDUAL_VALUES (
       p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
      ,x_return_status    OUT NOCOPY VARCHAR2
      ,x_msg_count        OUT NOCOPY NUMBER
      ,x_msg_data         OUT NOCOPY VARCHAR2
      ,P_ORG_ID           IN  NUMBER
      ,P_SO_ITEMS_ONLY_YN IN  VARCHAR2 -- get only items used in quoting
      ,P_START_DATE       IN  DATE
      ,P_END_DATE         IN  DATE
      ,P_TERM_LOWER_RANGE IN  NUMBER  -- MIN 1
      ,P_TERM_UPPER_RANGE IN  NUMBER
      ,P_TERM_INTERVAL    IN  NUMBER  -- IN MONTHS
      ,P_INITIAL_RV       IN  NUMBER  -- MAX 100
      ,P_DECREMENT_RV_BY  IN  NUMBER  -- MIN 1
      ,x_rv_tbl           OUT NOCOPY rv_tbl
     );

END OKL_RV_INTERFACE_PVT;

 

/
