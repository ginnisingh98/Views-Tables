--------------------------------------------------------
--  DDL for Package Body ASO_BI_POPULATE_APPR_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_POPULATE_APPR_FACTS" AS
 /* $Header: asovbiapfb.pls 115.3 2003/11/06 10:28:38 rkoratag noship $ */

-- 1 second
ONE_SECOND    CONSTANT NUMBER := 0.000011574;

--
-- Procedure for initial load of approvals
--
PROCEDURE Init_Load_Appr( errbuf    OUT NOCOPY VARCHAR2,
                          retcode     OUT NOCOPY NUMBER,
                          p_from_date IN  VARCHAR2,
                          p_to_date   IN  VARCHAR2 )
AS
 l_from_date  Date ;
 l_to_date	  Date;
 l_missing_date  Boolean := FALSE;
BEGIN
 retcode := 0 ;

 --Refresh Log
 BIS_COLLECTION_UTILITIES.deleteLogForObject('ASO_BI_POPULATE_APPR_FACTS');


 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_POPULATE_APPR_FACTS') = false)
 Then
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 End if;

 BIS_COLLECTION_UTILITIES.debug('Start Initial Load for approvals and rules Fact');

 -- Initialize
 BIS_COLLECTION_UTILITIES.debug('Initialization');

 ASO_BI_UTIL_PVT.INIT;

 -- Truncate the processing tables
 BIS_COLLECTION_UTILITIES.debug('Cleaning up the tables before processing starts.');

 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');

 --As this is a initial load the Base Fact Table is assumed to be empty
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_APR_F');
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_APR_RUL_F');

 l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
 l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 - ONE_SECOND;

 FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                  p_to_date   => l_to_date,
                                  p_has_missing_date => l_missing_date);

 If(l_missing_date) Then
  Retcode := -1;
  Return;
 End If;

 BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);

 BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));

 ASO_BI_QUOTE_FACT_PVT.InitLoad_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;

  BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));

  -- Call the initial load
	ASO_BI_APPR_FACT_PVT.Appr_Init_Load;
 	ASO_BI_APPR_FACT_PVT.Rul_Init_Load;

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

 retcode := 0;
EXCEPTION
WHEN OTHERS THEN
 retcode := -1;
 errbuf  := sqlerrm;
 BIS_COLLECTION_UTILITIES.Debug('Error in Initial Load of APPROVALS AND RULES Fact:'||errbuf);

 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
 RAISE;
end Init_Load_Appr;


--
-- Procedure for incremental load of approvals
--
PROCEDURE Incr_Load_Appr( errbuf    OUT NOCOPY VARCHAR2,
                          retcode   OUT NOCOPY NUMBER,
                          p_from_date IN  VARCHAR2,
                          p_to_date   IN  VARCHAR2 )
AS
 l_from_date  Date ;
 l_to_date	  Date;
 l_missing_date  Boolean := FALSE;
BEGIN
 retcode := 0 ;

 --Refresh Log
 BIS_COLLECTION_UTILITIES.deleteLogForObject('ASO_BI_POPULATE_APPR_FACTS');


 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_POPULATE_APPR_FACTS') = false)
 Then
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 End if;

 BIS_COLLECTION_UTILITIES.debug('Start Initial Load for approvals and rules Fact');

 -- Initialize
 BIS_COLLECTION_UTILITIES.debug('Initialization');

 ASO_BI_UTIL_PVT.INIT;

 -- Truncate the processing tables
 BIS_COLLECTION_UTILITIES.debug('Cleaning up the tables before processing starts.');
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');

 l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
 l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 - ONE_SECOND;

 FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                  p_to_date   => l_to_date,
                                  p_has_missing_date => l_missing_date);

 If(l_missing_date) Then
  Retcode := -1;
  Return;
 End If;

 BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);

 BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));

 -- Pick up all the modified quotes 4 d period
 ASO_BI_QUOTE_FACT_PVT.InitLoad_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;

 BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));

	ASO_BI_APPR_FACT_PVT.Appr_Incremental_Load;
 	ASO_BI_APPR_FACT_PVT.Rul_Incremental_Load;


  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

 retcode := 0;
EXCEPTION
WHEN OTHERS THEN
 retcode := -1;
 errbuf  := sqlerrm;
 BIS_COLLECTION_UTILITIES.Debug('Error in Initial Load of APPROVALS AND RULES Fact:'||errbuf);

 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
 RAISE;
end Incr_Load_Appr;

END ASO_BI_POPULATE_APPR_FACTS;

/
