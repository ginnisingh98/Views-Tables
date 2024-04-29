--------------------------------------------------------
--  DDL for Package Body QA_QWB_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_QWB_WRAPPER_PKG" AS
/* $Header: qaqwbwb.pls 120.3.12010000.1 2008/07/25 09:20:24 appldev ship $ */

/*
 * This Package is an API to inetrface with
 * Quality Work Bench. It has wrapper functions
 * that take in the resultString split into 66
 * segments each of 500 Chars. These are then
 * concatenated to form the final resultstring,
 * which is then passed to the actual functions.
 * This has been done to overcome the 4K size
 * limitation imposed while binding VARCHAR2
 * values while making a JDBC call
*/

   result_string VARCHAR2(32767);

   -- Wrapper function over
   -- QA_PARENT_CHILD_PKG.APPLICABLE_CHILD_PLANS
   -- ntungare Tue Apr 18 22:10:23 PDT 2006
   --
  FUNCTION APPLICABLE_CHILD_PLANS (p_plan_id   IN NUMBER,
                                   p_string1   IN VARCHAR2,
                                   p_string2   IN VARCHAR2,
                                   p_string3   IN VARCHAR2,
                                   p_string4   IN VARCHAR2,
                                   p_string5   IN VARCHAR2,
                                   p_string6   IN VARCHAR2,
                                   p_string7   IN VARCHAR2,
                                   p_string8   IN VARCHAR2,
                                   p_string9   IN VARCHAR2,
                                   p_string10  IN VARCHAR2,
                                   p_string11  IN VARCHAR2,
                                   p_string12  IN VARCHAR2,
                                   p_string13  IN VARCHAR2,
                                   p_string14  IN VARCHAR2,
                                   p_string15  IN VARCHAR2,
                                   p_string16  IN VARCHAR2,
                                   p_string17  IN VARCHAR2,
                                   p_string18  IN VARCHAR2,
                                   p_string19  IN VARCHAR2,
                                   p_string20  IN VARCHAR2,
                                   p_string21  IN VARCHAR2,
                                   p_string22  IN VARCHAR2,
                                   p_string23  IN VARCHAR2,
                                   p_string24  IN VARCHAR2,
                                   p_string25  IN VARCHAR2,
                                   p_string26  IN VARCHAR2,
                                   p_string27  IN VARCHAR2,
                                   p_string28  IN VARCHAR2,
                                   p_string29  IN VARCHAR2,
                                   p_string30  IN VARCHAR2,
                                   p_string31  IN VARCHAR2,
                                   p_string32  IN VARCHAR2,
                                   p_string33  IN VARCHAR2,
                                   p_string34  IN VARCHAR2,
                                   p_string35  IN VARCHAR2,
                                   p_string36  IN VARCHAR2,
                                   p_string37  IN VARCHAR2,
                                   p_string38  IN VARCHAR2,
                                   p_string39  IN VARCHAR2,
                                   p_string40  IN VARCHAR2,
                                   p_string41  IN VARCHAR2,
                                   p_string42  IN VARCHAR2,
                                   p_string43  IN VARCHAR2,
                                   p_string44  IN VARCHAR2,
                                   p_string45  IN VARCHAR2,
                                   p_string46  IN VARCHAR2,
                                   p_string47  IN VARCHAR2,
                                   p_string48  IN VARCHAR2,
                                   p_string49  IN VARCHAR2,
                                   p_string50  IN VARCHAR2,
                                   p_string51  IN VARCHAR2,
                                   p_string52  IN VARCHAR2,
                                   p_string53  IN VARCHAR2,
                                   p_string54  IN VARCHAR2,
                                   p_string55  IN VARCHAR2,
                                   p_string56  IN VARCHAR2,
                                   p_string57  IN VARCHAR2,
                                   p_string58  IN VARCHAR2,
                                   p_string59  IN VARCHAR2,
                                   p_string60  IN VARCHAR2,
                                   p_string61  IN VARCHAR2,
                                   p_string62  IN VARCHAR2,
                                   p_string63  IN VARCHAR2,
                                   p_string64  IN VARCHAR2,
                                   p_string65  IN VARCHAR2,
                                   p_string66  IN VARCHAR2)
           RETURN VARCHAR2 AS
   BEGIN
      -- Concatenating the result String segments
      result_string := p_string1||p_string2||p_string3||p_string4||p_string5||
                       p_string6||p_string7||p_string8||p_string9||p_string10||
                       p_string11||p_string12||p_string13||p_string14||p_string15||
                       p_string16||p_string17||p_string18||p_string19||p_string20||
                       p_string21||p_string22||p_string23||p_string24||p_string25||
                       p_string26||p_string27||p_string28||p_string29||p_string30||
                       p_string31||p_string32||p_string33||p_string34||p_string35||
                       p_string36||p_string37||p_string38||p_string39||p_string40||
                       p_string41||p_string42||p_string43||p_string44||p_string45||
                       p_string46||p_string47||p_string48||p_string49||p_string50||
                       p_string51||p_string52||p_string53||p_string54||p_string55||
                       p_string56||p_string57||p_string58||p_string59||p_string60||
                       p_string61||p_string62||p_string63||p_string64||p_string65||
                       p_string66;

      RETURN  QA_PARENT_CHILD_PKG.APPLICABLE_CHILD_PLANS
                      (p_plan_id         => p_plan_id,
                       p_criteria_values => result_string);

   END APPLICABLE_CHILD_PLANS;

   -- Wrapper function over
   -- QA_PARENT_CHILD_PKG.APPLICABLE_CHILD_PLANS_EQR
   -- ntungare Tue Apr 18 22:10:23 PDT 2006
   --
   FUNCTION APPLICABLE_CHILD_PLANS_EQR (p_plan_id   IN NUMBER,
                                        p_string1   IN VARCHAR2,
                                        p_string2   IN VARCHAR2,
                                        p_string3   IN VARCHAR2,
                                        p_string4   IN VARCHAR2,
                                        p_string5   IN VARCHAR2,
                                        p_string6   IN VARCHAR2,
                                        p_string7   IN VARCHAR2,
                                        p_string8   IN VARCHAR2,
                                        p_string9   IN VARCHAR2,
                                        p_string10  IN VARCHAR2,
                                        p_string11  IN VARCHAR2,
                                        p_string12  IN VARCHAR2,
                                        p_string13  IN VARCHAR2,
                                        p_string14  IN VARCHAR2,
                                        p_string15  IN VARCHAR2,
                                        p_string16  IN VARCHAR2,
                                        p_string17  IN VARCHAR2,
                                        p_string18  IN VARCHAR2,
                                        p_string19  IN VARCHAR2,
                                        p_string20  IN VARCHAR2,
                                        p_string21  IN VARCHAR2,
                                        p_string22  IN VARCHAR2,
                                        p_string23  IN VARCHAR2,
                                        p_string24  IN VARCHAR2,
                                        p_string25  IN VARCHAR2,
                                        p_string26  IN VARCHAR2,
                                        p_string27  IN VARCHAR2,
                                        p_string28  IN VARCHAR2,
                                        p_string29  IN VARCHAR2,
                                        p_string30  IN VARCHAR2,
                                        p_string31  IN VARCHAR2,
                                        p_string32  IN VARCHAR2,
                                        p_string33  IN VARCHAR2,
                                        p_string34  IN VARCHAR2,
                                        p_string35  IN VARCHAR2,
                                        p_string36  IN VARCHAR2,
                                        p_string37  IN VARCHAR2,
                                        p_string38  IN VARCHAR2,
                                        p_string39  IN VARCHAR2,
                                        p_string40  IN VARCHAR2,
                                        p_string41  IN VARCHAR2,
                                        p_string42  IN VARCHAR2,
                                        p_string43  IN VARCHAR2,
                                        p_string44  IN VARCHAR2,
                                        p_string45  IN VARCHAR2,
                                        p_string46  IN VARCHAR2,
                                        p_string47  IN VARCHAR2,
                                        p_string48  IN VARCHAR2,
                                        p_string49  IN VARCHAR2,
                                        p_string50  IN VARCHAR2,
                                        p_string51  IN VARCHAR2,
                                        p_string52  IN VARCHAR2,
                                        p_string53  IN VARCHAR2,
                                        p_string54  IN VARCHAR2,
                                        p_string55  IN VARCHAR2,
                                        p_string56  IN VARCHAR2,
                                        p_string57  IN VARCHAR2,
                                        p_string58  IN VARCHAR2,
                                        p_string59  IN VARCHAR2,
                                        p_string60  IN VARCHAR2,
                                        p_string61  IN VARCHAR2,
                                        p_string62  IN VARCHAR2,
                                        p_string63  IN VARCHAR2,
                                        p_string64  IN VARCHAR2,
                                        p_string65  IN VARCHAR2,
                                        p_string66  IN VARCHAR2)
           RETURN VARCHAR2 AS
   BEGIN
      -- Concatenating the result String segments
      result_string := p_string1||p_string2||p_string3||p_string4||p_string5||
                       p_string6||p_string7||p_string8||p_string9||p_string10||
                       p_string11||p_string12||p_string13||p_string14||p_string15||
                       p_string16||p_string17||p_string18||p_string19||p_string20||
                       p_string21||p_string22||p_string23||p_string24||p_string25||
                       p_string26||p_string27||p_string28||p_string29||p_string30||
                       p_string31||p_string32||p_string33||p_string34||p_string35||
                       p_string36||p_string37||p_string38||p_string39||p_string40||
                       p_string41||p_string42||p_string43||p_string44||p_string45||
                       p_string46||p_string47||p_string48||p_string49||p_string50||
                       p_string51||p_string52||p_string53||p_string54||p_string55||
                       p_string56||p_string57||p_string58||p_string59||p_string60||
                       p_string61||p_string62||p_string63||p_string64||p_string65||
                       p_string66;

      RETURN QA_PARENT_CHILD_PKG.APPLICABLE_CHILD_PLANS_EQR
                      (p_plan_id         => p_plan_id,
                       p_criteria_values => result_string);

   END APPLICABLE_CHILD_PLANS_EQR;

-- Wrapper function over
-- QA_SS_RESULTS.SSQR_VALIDATE_ROW
-- ntungare Tue Apr 18 22:10:23 PDT 2006
--
--
-- 12.1 QWB Usability Improvements
-- Added 2 ne wparameters one to rerurn a comma separated
-- list of the HC elements and the other to return a comma
-- separated list of the Normalized Ids
--
FUNCTION SSQR_VALIDATE_ROW (p_occurrence IN OUT NOCOPY NUMBER,
                            p_org_id     IN NUMBER,
                            p_plan_id    IN NUMBER,
                            p_spec_id    IN NUMBER,
                            p_collection_id IN NUMBER,
                            p_result1    IN VARCHAR2,
                            p_result2    IN VARCHAR2,
                            p_enabled    IN INTEGER,
                            p_committed  IN INTEGER,
                            p_transaction_number IN NUMBER,
                            p_transaction_id IN  NUMBER DEFAULT 0,
                            p_string1   IN VARCHAR2,
                            p_string2   IN VARCHAR2,
                            p_string3   IN VARCHAR2,
                            p_string4   IN VARCHAR2,
                            p_string5   IN VARCHAR2,
                            p_string6   IN VARCHAR2,
                            p_string7   IN VARCHAR2,
                            p_string8   IN VARCHAR2,
                            p_string9   IN VARCHAR2,
                            p_string10  IN VARCHAR2,
                            p_string11  IN VARCHAR2,
                            p_string12  IN VARCHAR2,
                            p_string13  IN VARCHAR2,
                            p_string14  IN VARCHAR2,
                            p_string15  IN VARCHAR2,
                            p_string16  IN VARCHAR2,
                            p_string17  IN VARCHAR2,
                            p_string18  IN VARCHAR2,
                            p_string19  IN VARCHAR2,
                            p_string20  IN VARCHAR2,
                            p_string21  IN VARCHAR2,
                            p_string22  IN VARCHAR2,
                            p_string23  IN VARCHAR2,
                            p_string24  IN VARCHAR2,
                            p_string25  IN VARCHAR2,
                            p_string26  IN VARCHAR2,
                            p_string27  IN VARCHAR2,
                            p_string28  IN VARCHAR2,
                            p_string29  IN VARCHAR2,
                            p_string30  IN VARCHAR2,
                            p_string31  IN VARCHAR2,
                            p_string32  IN VARCHAR2,
                            p_string33  IN VARCHAR2,
                            p_string34  IN VARCHAR2,
                            p_string35  IN VARCHAR2,
                            p_string36  IN VARCHAR2,
                            p_string37  IN VARCHAR2,
                            p_string38  IN VARCHAR2,
                            p_string39  IN VARCHAR2,
                            p_string40  IN VARCHAR2,
                            p_string41  IN VARCHAR2,
                            p_string42  IN VARCHAR2,
                            p_string43  IN VARCHAR2,
                            p_string44  IN VARCHAR2,
                            p_string45  IN VARCHAR2,
                            p_string46  IN VARCHAR2,
                            p_string47  IN VARCHAR2,
                            p_string48  IN VARCHAR2,
                            p_string49  IN VARCHAR2,
                            p_string50  IN VARCHAR2,
                            p_string51  IN VARCHAR2,
                            p_string52  IN VARCHAR2,
                            p_string53  IN VARCHAR2,
                            p_string54  IN VARCHAR2,
                            p_string55  IN VARCHAR2,
                            p_string56  IN VARCHAR2,
                            p_string57  IN VARCHAR2,
                            p_string58  IN VARCHAR2,
                            p_string59  IN VARCHAR2,
                            p_string60  IN VARCHAR2,
                            p_string61  IN VARCHAR2,
                            p_string62  IN VARCHAR2,
                            p_string63  IN VARCHAR2,
                            p_string64  IN VARCHAR2,
                            p_string65  IN VARCHAR2,
                            p_string66  IN VARCHAR2,
                            x_messages OUT NOCOPY VARCHAR2,
                            x_charid_str OUT NOCOPY VARCHAR2,
                            x_id_str OUT NOCOPY VARCHAR2)
       RETURN INTEGER AS
   BEGIN
      -- Concatenating the result String segments
      result_string := p_string1||p_string2||p_string3||p_string4||p_string5||
                       p_string6||p_string7||p_string8||p_string9||p_string10||
                       p_string11||p_string12||p_string13||p_string14||p_string15||
                       p_string16||p_string17||p_string18||p_string19||p_string20||
                       p_string21||p_string22||p_string23||p_string24||p_string25||
                       p_string26||p_string27||p_string28||p_string29||p_string30||
                       p_string31||p_string32||p_string33||p_string34||p_string35||
                       p_string36||p_string37||p_string38||p_string39||p_string40||
                       p_string41||p_string42||p_string43||p_string44||p_string45||
                       p_string46||p_string47||p_string48||p_string49||p_string50||
                       p_string51||p_string52||p_string53||p_string54||p_string55||
                       p_string56||p_string57||p_string58||p_string59||p_string60||
                       p_string61||p_string62||p_string63||p_string64||p_string65||
                       P_string66;

      RETURN QA_SS_RESULTS.SSQR_VALIDATE_ROW
                      (p_occurrence         => p_occurrence,
                       p_org_id             => p_org_id,
                       p_plan_id            => p_plan_id,
                       p_spec_id            => p_spec_id,
                       p_collection_id      => p_collection_id,
                       p_result             => result_string,
                       p_result1            => p_result1,
                       p_result2            => p_result2,
                       p_enabled            => p_enabled,
                       p_committed          => p_committed,
                       p_transaction_number => p_transaction_number,
                       p_transaction_id     => p_transaction_id,
                       x_messages           => x_messages,
                       x_charid_str         => x_charid_str,
                       x_id_str             => x_id_str);

   END SSQR_VALIDATE_ROW;

  -- Wrapper function over
  -- QA_SS_RESULTS.SSQR_POST_RESULT
  -- ntungare Tue Apr 18 22:10:23 PDT 2006
  --
  --
  -- 12.1 QWB Usability Improvements
  -- added 2 new elements, one a comma separated list of the
  -- Parent collection elements that would receive aggregated
  -- values and the other a comma separated list of the
  -- aggregated values.
  --
   FUNCTION SSQR_POST_RESULT(x_occurrence IN OUT NOCOPY NUMBER,
                             x_org_id     IN NUMBER,
                             x_plan_id    IN NUMBER,
                             x_spec_id    IN NUMBER,
                             x_collection_id IN NUMBER,
                             x_txn_header_id IN NUMBER,
                             x_par_plan_id   IN NUMBER,
                             x_par_col_id    IN NUMBER,
                             x_par_occ       IN NUMBER,
                             x_result1       IN VARCHAR2,
                             x_result2       IN VARCHAR2,
                             x_enabled       IN INTEGER,
                             x_committed     IN INTEGER,
                             x_transaction_number IN NUMBER,
                             p_string1   IN VARCHAR2,
                             p_string2   IN VARCHAR2,
                             p_string3   IN VARCHAR2,
                             p_string4   IN VARCHAR2,
                             p_string5   IN VARCHAR2,
                             p_string6   IN VARCHAR2,
                             p_string7   IN VARCHAR2,
                             p_string8   IN VARCHAR2,
                             p_string9   IN VARCHAR2,
                             p_string10  IN VARCHAR2,
                             p_string11  IN VARCHAR2,
                             p_string12  IN VARCHAR2,
                             p_string13  IN VARCHAR2,
                             p_string14  IN VARCHAR2,
                             p_string15  IN VARCHAR2,
                             p_string16  IN VARCHAR2,
                             p_string17  IN VARCHAR2,
                             p_string18  IN VARCHAR2,
                             p_string19  IN VARCHAR2,
                             p_string20  IN VARCHAR2,
                             p_string21  IN VARCHAR2,
                             p_string22  IN VARCHAR2,
                             p_string23  IN VARCHAR2,
                             p_string24  IN VARCHAR2,
                             p_string25  IN VARCHAR2,
                             p_string26  IN VARCHAR2,
                             p_string27  IN VARCHAR2,
                             p_string28  IN VARCHAR2,
                             p_string29  IN VARCHAR2,
                             p_string30  IN VARCHAR2,
                             p_string31  IN VARCHAR2,
                             p_string32  IN VARCHAR2,
                             p_string33  IN VARCHAR2,
                             p_string34  IN VARCHAR2,
                             p_string35  IN VARCHAR2,
                             p_string36  IN VARCHAR2,
                             p_string37  IN VARCHAR2,
                             p_string38  IN VARCHAR2,
                             p_string39  IN VARCHAR2,
                             p_string40  IN VARCHAR2,
                             p_string41  IN VARCHAR2,
                             p_string42  IN VARCHAR2,
                             p_string43  IN VARCHAR2,
                             p_string44  IN VARCHAR2,
                             p_string45  IN VARCHAR2,
                             p_string46  IN VARCHAR2,
                             p_string47  IN VARCHAR2,
                             p_string48  IN VARCHAR2,
                             p_string49  IN VARCHAR2,
                             p_string50  IN VARCHAR2,
                             p_string51  IN VARCHAR2,
                             p_string52  IN VARCHAR2,
                             p_string53  IN VARCHAR2,
                             p_string54  IN VARCHAR2,
                             p_string55  IN VARCHAR2,
                             p_string56  IN VARCHAR2,
                             p_string57  IN VARCHAR2,
                             p_string58  IN VARCHAR2,
                             p_string59  IN VARCHAR2,
                             p_string60  IN VARCHAR2,
                             p_string61  IN VARCHAR2,
                             p_string62  IN VARCHAR2,
                             p_string63  IN VARCHAR2,
                             p_string64  IN VARCHAR2,
                             p_string65  IN VARCHAR2,
                             p_string66  IN VARCHAR2,
                             x_messages OUT NOCOPY VARCHAR2,
                             x_agg_elements OUT NOCOPY VARCHAR2,
                             x_agg_val OUT NOCOPY VARCHAR2,
                             p_last_update_date IN DATE DEFAULT SYSDATE)
      RETURN INTEGER AS
   BEGIN
      -- Concatenating the result String segments
      result_string := p_string1||p_string2||p_string3||p_string4||p_string5||
                       p_string6||p_string7||p_string8||p_string9||p_string10||
                       p_string11||p_string12||p_string13||p_string14||p_string15||
                       p_string16||p_string17||p_string18||p_string19||p_string20||
                       p_string21||p_string22||p_string23||p_string24||p_string25||
                       p_string26||p_string27||p_string28||p_string29||p_string30||
                       p_string31||p_string32||p_string33||p_string34||p_string35||
                       p_string36||p_string37||p_string38||p_string39||p_string40||
                       p_string41||p_string42||p_string43||p_string44||p_string45||
                       p_string46||p_string47||p_string48||p_string49||p_string50||
                       p_string51||p_string52||p_string53||p_string54||p_string55||
                       p_string56||p_string57||p_string58||p_string59||p_string60||
                       p_string61||p_string62||p_string63||p_string64||p_string65||
                       p_string66;

      RETURN QA_SS_RESULTS.SSQR_POST_RESULT
                      (x_occurrence         => x_occurrence,
                       x_org_id             => x_org_id,
                       x_plan_id            => x_plan_id,
                       x_spec_id            => x_spec_id,
                       x_collection_id      => x_collection_id,
                       x_txn_header_id      => x_txn_header_id,
                       x_par_plan_id        => x_par_plan_id,
                       x_par_col_id         => x_par_col_id,
                       x_par_occ            => x_par_occ,
                       x_result             => result_string,
                       x_result1            => x_result1,
                       x_result2            => x_result2,
                       x_enabled            => x_enabled,
                       x_committed          => x_committed,
                       x_transaction_number => x_transaction_number,
                       x_messages           => x_messages,
                       x_agg_elements       => x_agg_elements,
                       x_agg_val            => x_agg_val,
                       p_last_update_date   => p_last_update_date);

   END SSQR_POST_RESULT;

 -- Wrapper function over
 -- QA_SS_RESULTS.SSQR_UPDATE_RESULT
 -- ntungare Tue Apr 18 22:10:23 PDT 2006
 --
 -- Bug 6881303
 -- added 2 new elements, one a comma separated list of the
 -- Parent collection elements that would receive aggregated
 -- values and the other a comma separated list of the
 -- aggregated values.
 -- ntungare Fri Mar 21 01:19:03 PDT 2008
 --
FUNCTION SSQR_UPDATE_RESULT(x_occurrence IN NUMBER,
                            x_org_id     IN NUMBER,
                            x_plan_id    IN NUMBER,
                            x_spec_id    IN NUMBER,
                            x_collection_id IN NUMBER,
                            x_txn_header_id IN NUMBER,
                            x_par_plan_id   IN NUMBER,
                            x_par_col_id    IN NUMBER,
                            x_par_occ       IN NUMBER,
                            x_result1       IN VARCHAR2,
                            x_result2       IN VARCHAR2,
                            x_enabled       IN INTEGER,
                            x_committed     IN INTEGER,
                            x_transaction_number IN NUMBER,
                            p_string1   IN VARCHAR2,
                            p_string2   IN VARCHAR2,
                            p_string3   IN VARCHAR2,
                            p_string4   IN VARCHAR2,
                            p_string5   IN VARCHAR2,
                            p_string6   IN VARCHAR2,
                            p_string7   IN VARCHAR2,
                            p_string8   IN VARCHAR2,
                            p_string9   IN VARCHAR2,
                            p_string10  IN VARCHAR2,
                            p_string11  IN VARCHAR2,
                            p_string12  IN VARCHAR2,
                            p_string13  IN VARCHAR2,
                            p_string14  IN VARCHAR2,
                            p_string15  IN VARCHAR2,
                            p_string16  IN VARCHAR2,
                            p_string17  IN VARCHAR2,
                            p_string18  IN VARCHAR2,
                            p_string19  IN VARCHAR2,
                            p_string20  IN VARCHAR2,
                            p_string21  IN VARCHAR2,
                            p_string22  IN VARCHAR2,
                            p_string23  IN VARCHAR2,
                            p_string24  IN VARCHAR2,
                            p_string25  IN VARCHAR2,
                            p_string26  IN VARCHAR2,
                            p_string27  IN VARCHAR2,
                            p_string28  IN VARCHAR2,
                            p_string29  IN VARCHAR2,
                            p_string30  IN VARCHAR2,
                            p_string31  IN VARCHAR2,
                            p_string32  IN VARCHAR2,
                            p_string33  IN VARCHAR2,
                            p_string34  IN VARCHAR2,
                            p_string35  IN VARCHAR2,
                            p_string36  IN VARCHAR2,
                            p_string37  IN VARCHAR2,
                            p_string38  IN VARCHAR2,
                            p_string39  IN VARCHAR2,
                            p_string40  IN VARCHAR2,
                            p_string41  IN VARCHAR2,
                            p_string42  IN VARCHAR2,
                            p_string43  IN VARCHAR2,
                            p_string44  IN VARCHAR2,
                            p_string45  IN VARCHAR2,
                            p_string46  IN VARCHAR2,
                            p_string47  IN VARCHAR2,
                            p_string48  IN VARCHAR2,
                            p_string49  IN VARCHAR2,
                            p_string50  IN VARCHAR2,
                            p_string51  IN VARCHAR2,
                            p_string52  IN VARCHAR2,
                            p_string53  IN VARCHAR2,
                            p_string54  IN VARCHAR2,
                            p_string55  IN VARCHAR2,
                            p_string56  IN VARCHAR2,
                            p_string57  IN VARCHAR2,
                            p_string58  IN VARCHAR2,
                            p_string59  IN VARCHAR2,
                            p_string60  IN VARCHAR2,
                            p_string61  IN VARCHAR2,
                            p_string62  IN VARCHAR2,
                            p_string63  IN VARCHAR2,
                            p_string64  IN VARCHAR2,
                            p_string65  IN VARCHAR2,
                            p_string66  IN VARCHAR2,
                            x_messages OUT NOCOPY VARCHAR2,
                            x_agg_elements OUT NOCOPY VARCHAR2,
                            x_agg_val OUT NOCOPY VARCHAR2,
                            p_last_update_date IN DATE DEFAULT SYSDATE)

    RETURN INTEGER AS
  BEGIN
      -- Concatenating the result String segments
      result_string := p_string1||p_string2||p_string3||p_string4||p_string5||
                       p_string6||p_string7||p_string8||p_string9||p_string10||
                       p_string11||p_string12||p_string13||p_string14||p_string15||
                       p_string16||p_string17||p_string18||p_string19||p_string20||
                       p_string21||p_string22||p_string23||p_string24||p_string25||
                       p_string26||p_string27||p_string28||p_string29||p_string30||
                       p_string31||p_string32||p_string33||p_string34||p_string35||
                       p_string36||p_string37||p_string38||p_string39||p_string40||
                       p_string41||p_string42||p_string43||p_string44||p_string45||
                       p_string46||p_string47||p_string48||p_string49||p_string50||
                       p_string51||p_string52||p_string53||p_string54||p_string55||
                       p_string56||p_string57||p_string58||p_string59||p_string60||
                       p_string61||p_string62||p_string63||p_string64||p_string65||
                       P_string66;

      RETURN QA_SS_RESULTS.SSQR_UPDATE_RESULT
                      (x_occurrence         => x_occurrence,
                       x_org_id             => x_org_id,
                       x_plan_id            => x_plan_id,
                       x_spec_id            => x_spec_id,
                       x_collection_id      => x_collection_id,
                       x_txn_header_id      => x_txn_header_id,
                       x_par_plan_id        => x_par_plan_id,
                       x_par_col_id         => x_par_col_id,
                       x_par_occ            => x_par_occ,
                       x_result             => result_string,
                       x_result1            => x_result1,
                       x_result2            => x_result2,
                       x_enabled            => x_enabled,
                       x_committed          => x_committed,
                       x_transaction_number => x_transaction_number,
                       x_messages           => x_messages,
                       x_agg_elements       => x_agg_elements,
                       x_agg_val            => x_agg_val,
                       p_last_update_date   => p_last_update_date);

  END SSQR_UPDATE_RESULT;

END qa_qwb_wrapper_pkg;

/
