--------------------------------------------------------
--  DDL for Package IBY_FACTOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FACTOR_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyfacts.pls 115.7 2002/11/18 23:02:10 jleybovi ship $*/

  /* Amount Range Record used in PaymentAmount Factor*/
  TYPE Amount_Range is RECORD (LowAmtLmt Number, UprAmtLmt Number,
                               Seq integer, Score VARCHAR2(10));
  /* Time Range Recores  used in Time of Purchase */
  TYPE Time_Range is RECORD (LowTimeLmt integer, UprTimeLmt integer,
                               Seq integer, Score VARCHAR2(10));
  /* Frequncy Range Record used in Payment History*/
  TYPE Freq_Range is RECORD (LowFreqLmt integer, UprFreqLmt integer,
                               Seq integer, Score VARCHAR2(10));
  /* Codes Range Record AVSCodes, RiskCodes and CreditRating Codes */
  TYPE codes is RECORD (code VARCHAR2(30), Score VARCHAR2(10));

  TYPE AmountRange_table IS TABLE OF Amount_Range INDEX BY BINARY_INTEGER;
  TYPE FreqRange_table IS TABLE OF Freq_Range INDEX BY BINARY_INTEGER;
  TYPE TimeRange_table IS TABLE OF Time_Range INDEX BY BINARY_INTEGER;
  TYPE codes_table IS TABLE OF codes INDEX BY BINARY_INTEGER;

  /*
  ** Procedure: save_PaymentAmount
  ** Purpose: Saves the PaymentAmount factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */

  procedure save_PaymentAmount( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_amountRanges in AmountRange_table );

  /*
  ** Procedure: load_PaymentAmount
  ** Purpose: loads  the PaymentAmount factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          creates new entries.
  */
  procedure load_PaymentAmount( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_amountRanges out nocopy AmountRange_table );

  /*
  ** Procedure: save_TimeOfPurchase
  ** Purpose: Saves the TimeOfPurchase factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_TimeOfPurchase( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_timeRanges in TimeRange_table );

  /*
  ** Procedure: load_TimeOfPurchase
  ** Purpose: loads  the TimeOfPurchase factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level entries.
  */
  procedure load_TimeOfPurchase( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_timeRanges out nocopy TimeRange_table );

  /*
  ** Procedure: save_TrxnAmountLimit
  ** Purpose: Saves the TrxnAmountLimit factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_TrxnAmountLimit( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_amount in number );

  /*
  ** Procedure: load_TrxnAmountLimit
  ** Purpose: loads  the TrxnAmountLimit factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level entries.
  */
  procedure load_TrxnAmountLimit( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_amount out nocopy number );

  /*
  ** Procedure: save_PaymentHistory
  ** Purpose: Saves the PaymentHistory factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_PaymentHistory(i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_count in integer,
                                i_freqRanges in FreqRange_table );

  /*
  ** Procedure: load_PaymentHistory
  ** Purpose: loads  the PaymentHistory factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level Payemnet History values.
  */
  procedure load_PaymentHistory(i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_freqRanges out nocopy FreqRange_table );

  /*
  ** Procedure: save_AVSCodes
  ** Purpose: Saves the AVSCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_AVSCodes( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                           i_description in VARCHAR2,
                           i_count in integer,
                           i_codes in codes_table );

  /*
  ** Procedure: load_AVSCodes
  ** Purpose: loads  the AVSCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads AVSCodes of the site level.
  */
  procedure load_AVSCodes( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                           o_description out nocopy VARCHAR2,
                           o_codes out nocopy codes_table );

  /*
  ** Procedure: save_RiskCodes
  ** Purpose: Saves the RiskCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_RiskCodes( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                            i_description in VARCHAR2,
                            i_count in integer,
                            i_codes in codes_table );

  /*
  ** Procedure: load_RiskCodes
  ** Purpose: loads  the RiskCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the sitelevel  entries.
  */
  procedure load_RiskCodes( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                            o_description out nocopy VARCHAR2,
                            o_codes out nocopy codes_table );

  /*
  ** Procedure: save_CreditRatingCodes
  ** Purpose: Saves the CreditRatingCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_CreditRatingCodes( i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_codes in codes_table );

  /*
  ** Procedure: load_CreditRatingCodes
  ** Purpose: loads  the CreditRatingCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads new entries.
  */
  procedure load_CreditRatingCodes( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_codes out nocopy codes_table );

  /*
  ** Procedure: save_FreqOfPurchase
  ** Purpose: Saves the FreqOfPurchase factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_FreqOfPurchase(i_payeeid in varchar2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_frequency in integer );

  /*
  ** Procedure: load_FreqOfPurchase
  ** Purpose: loads  the FreqOfPurchase factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          creates new entries.
  */
  procedure load_FreqOfPurchase(i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_frequency out nocopy integer );

  /*
  ** Procedure: save_RiskScores
  ** Purpose: Saves the RiskScores information into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level RiskScores values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_RiskScores(    i_payeeid in varchar2,
                                i_lowval in integer,
                                i_lowMedVal in integer,
                                i_medVal in integer,
                                i_medHighVal in integer,
                                i_highVal in integer );

  /*
  ** Procedure: load_RiskScores
  ** Purpose: loads  the RiskScores information into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level RiskScore values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          retrieves new entries.
  */
  procedure load_RiskScores(    i_payeeid in varchar2,
                                o_lowval out nocopy integer,
                                o_lowMedVal out nocopy integer,
                                o_medVal out nocopy integer,
                                o_medHighVal out nocopy integer,
                                o_highVal out nocopy integer );

end iby_factor_pkg;



 

/
