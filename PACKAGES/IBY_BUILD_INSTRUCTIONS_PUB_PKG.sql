--------------------------------------------------------
--  DDL for Package IBY_BUILD_INSTRUCTIONS_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BUILD_INSTRUCTIONS_PUB_PKG" AUTHID CURRENT_USER AS
/*$Header: ibypayis.pls 120.13.12010000.1 2008/07/28 05:41:32 appldev ship $*/

/*--------------------------------------------------------------------
 | NAME:
 |     build_pmt_instructions
 |
 | PURPOSE:
 |     This is the top level procedure of the payment instruction
 |     creation program; This procedure will run as a concurrent program.
 |
 | PARAMETERS:
 |     IN
 |
 |     p_calling_app_id
 |         The 3-character product code of the calling application
 |
 |     p_calling_app_payreq_cd
 |         Id of the payment service request from the calling app's
 |         point of view. For a given calling app, this id should be
 |         unique; the build program will communicate back to the calling
 |         app using this payment request id.
 |
 |    p_internal_bank_account_id
 |        The internal bank account to pay from.
 |
 |    p_payment_profile_id
 |        Payment profile
 |
 |    p_allow_zero_payments_flag
 |        'Y' / 'N' flag indicating whether zero value payments are allowed.
 |        If not set, this value will be defaulted to 'Y'.
 |
 |    p_payment_date
 |        The payment date.
 |
 |    p_anticipated_value_date
 |        The anticipated value date.
 |
 |     p_args10 - p_args100
 |         These 91 parameters are mandatory for any stored procedure
 |         that is submitted from Oracle Forms as a concurrent request
 |         (to get the total number of args to the concurrent procedure
 |          to 100).
 |
 |     OUT
 |
 |     x_errbuf
 |     x_retcode
 |
 |         These two are mandatory output paramaters for a concurrent
 |         program. They will store the error message and error code
 |         to indicate a successful/failed run of the concurrent request.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE build_pmt_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL, /* dummy */
     p_pmt_document_id            IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_print_now_flag             IN         VARCHAR2 DEFAULT NULL,
     p_printer_name               IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_transmit_now_flag          IN         VARCHAR2 DEFAULT NULL,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,

     p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     rebuild_pmt_instruction
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE rebuild_pmt_instruction(
     x_errbuf         OUT NOCOPY VARCHAR2,
     x_retcode        OUT NOCOPY VARCHAR2,
     p_pmt_instr_id   IN         VARCHAR2,
     p_arg4   IN VARCHAR2 DEFAULT NULL, p_arg5   IN VARCHAR2 DEFAULT NULL,
     p_arg6   IN VARCHAR2 DEFAULT NULL, p_arg7   IN VARCHAR2 DEFAULT NULL,
     p_arg8   IN VARCHAR2 DEFAULT NULL, p_arg9   IN VARCHAR2 DEFAULT NULL,
     p_arg10  IN VARCHAR2 DEFAULT NULL, p_arg11  IN VARCHAR2 DEFAULT NULL,
     p_arg12  IN VARCHAR2 DEFAULT NULL, p_arg13  IN VARCHAR2 DEFAULT NULL,
     p_arg14  IN VARCHAR2 DEFAULT NULL, p_arg15  IN VARCHAR2 DEFAULT NULL,
     p_arg16  IN VARCHAR2 DEFAULT NULL, p_arg17  IN VARCHAR2 DEFAULT NULL,
     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     moveInstrToDeferredStatus
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE moveInstrToDeferredStatus(
     p_pmtInstrTab       IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtInstrTabType,
     p_instr_to_skip     IN IBY_PAY_INSTRUCTIONS_ALL.
                                payment_instruction_id%TYPE DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_id
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_payreq_id (
     l_ca_id        IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     l_ca_payreq_cd IN IBY_PAY_SERVICE_REQUESTS.
                           call_app_pay_service_req_code%TYPE
     )
     RETURN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;

/*--------------------------------------------------------------------
 | NAME:
 |     get_instruction_attributes
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_instruction_attributes(
     l_pmt_instr_id IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE)
     RETURN IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2 DEFAULT FND_LOG.LEVEL_STATEMENT
     );

/*--------------------------------------------------------------------
 | NAME:
 |     build_electronic_instructions
 |
 | PURPOSE:
 |     Concurrent program wrapper for electronic payment instructions.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE build_electronic_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,
     p_transmit_now_flag          IN         VARCHAR2 DEFAULT NULL,

     p_arg16  IN VARCHAR2 DEFAULT NULL, p_arg17  IN VARCHAR2 DEFAULT NULL,
     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     build_printed_instructions
 |
 | PURPOSE:
 |     Concurrent program wrapper for printed payment instructions.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE build_printed_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_pmt_document_id            IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,
     p_print_now_flag             IN         VARCHAR2 DEFAULT NULL,
     p_printer_name               IN         VARCHAR2 DEFAULT NULL,

     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );


END IBY_BUILD_INSTRUCTIONS_PUB_PKG;

/
