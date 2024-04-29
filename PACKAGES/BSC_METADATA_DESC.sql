--------------------------------------------------------
--  DDL for Package BSC_METADATA_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_METADATA_DESC" AUTHID CURRENT_USER AS
/* $Header: BSCMDDS.pls 120.0 2005/06/01 15:35 appldev noship $ */
/*---------------------------------------------------------------------------------------*/
PROCEDURE Describe_kpi(
  p_kpi_id              IN             NUMBER
 ,x_query               OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

PROCEDURE Describe_kpi(
 p_kpi_id              IN      NUMBER
);
/*---------------------------------------------------------------------------------------*/
PROCEDURE Run_Concurrent_Describe_kpi (
    ERRBUF     OUT NOCOPY VARCHAR2
    ,RETCODE    OUT NOCOPY VARCHAR2
    ,p_kpi_id   IN         NUMBER
) ;


/*---------------------------------------------------------------------------------------*/
END  BSC_METADATA_DESC;

 

/
