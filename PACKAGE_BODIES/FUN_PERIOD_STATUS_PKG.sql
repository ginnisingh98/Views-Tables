--------------------------------------------------------
--  DDL for Package Body FUN_PERIOD_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_PERIOD_STATUS_PKG" AS
/*  $Header: funprdstsb.pls 120.19.12010000.6 2010/06/22 07:22:35 srsampat ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := ' FUN_PERIOD_STATUS_PKG';
G_DEBUG VARCHAR2(1);
        PROCEDURE Print
                        (
                       P_string                IN      VARCHAR2
                        ) IS
        BEGIN
        IF G_DEBUG = 'Y' THEN
                                fnd_file.put_line(FND_FILE.LOG, p_string);
        END IF;
        END Print;
/***********************************************
* Procedure Close_Period :
*                        This Procedure Closes specified Intercompany Period   *
*  or all the periods. It checks whether there are any Open Intercompany       *
*  Transactions. If Yes, then user can sweep the transactions to next open     *
*  period before closing the Period.                                           *
***************************************************/
        PROCEDURE Close_Period
        (
         p_api_version          IN NUMBER,
         p_init_msg_list        IN VARCHAR2 ,
         p_commit               IN VARCHAR2 ,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_message_count        OUT NOCOPY NUMBER,
         x_message_data         OUT NOCOPY VARCHAR2,
         p_period_name          IN VARCHAR2,
         p_trx_type_id          IN NUMBER,
         p_sweep                IN VARCHAR2,
         p_sweep_GL_date        IN DATE,
         x_request_id           OUT NOCOPY NUMBER
        ) IS
        Cursor c_open_trx1(l_prd_name in Varchar2,l_trx_type_id in Number)  is
                Select 1 from dual where exists
                (Select 'X' from fun_trx_batches ftb, fun_trx_headers fth,
        fun_period_statuses fps,fun_system_options fso where ftb.batch_id = fth.batch_id and
        ftb.gl_date >= fps.start_date and ftb.gl_date <=
        fps.end_date and fps.period_name = l_prd_name and
        fps.trx_type_id = l_trx_type_id and ftb.trx_type_id = l_trx_type_id and
	ftb.batch_id not in (SELECT h2.batch_id FROM fun_trx_headers h2
		     WHERE h2.status IN ('APPROVED', 'COMPLETE', 'XFER_RECI_GL',
	  'XFER_AR', 'XFER_INI_GL','XFER_AP','REJECTED')
		     AND   h2.batch_id = ftb.batch_id)                                     --  Bug No : 6880343
        AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
	AND fps.inteco_period_type =nvl(fso.inteco_period_type,'~~'));
        Cursor c_open_trx2(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X' from fun_trx_batches ftb, fun_trx_headers fth,
        fun_period_statuses fps,fun_system_options fso where ftb.batch_id = fth.batch_id and
        ftb.gl_date >= fps.start_date and ftb.gl_date <=
        fps.end_date and fps.period_name = l_prd_name
        and ftb.trx_type_id = fps.trx_type_id and
	ftb.batch_id not in (SELECT h2.batch_id FROM fun_trx_headers h2
		     WHERE h2.status IN ('APPROVED', 'COMPLETE', 'XFER_RECI_GL',
	  'XFER_AR', 'XFER_INI_GL','XFER_AP','REJECTED')
		     AND   h2.batch_id = ftb.batch_id)                                     --  Bug No : 6880343
	AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
	AND fps.inteco_period_type =nvl(fso.inteco_period_type,'~~'));
        Cursor c_open_prd1(l_prd_name in Varchar2, l_trx_type_id in
        Number)  is
                Select 1 from dual where exists
                (Select 'X' from fun_period_statuses fps,fun_system_options fso where fps.status = 'O'
        and trx_type_id = l_trx_type_id  and period_name = l_prd_name
	 AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
	AND fps.inteco_period_type =nvl(fso.inteco_period_type,'~~'));
        Cursor c_open_prd2(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X' from fun_period_statuses fps,fun_system_options fso where fps.status = 'O'
        and period_name = l_prd_name
	 AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
	AND fps.inteco_period_type =nvl(fso.inteco_period_type,'~~'));
        l_api_name              CONSTANT VARCHAR2(30) := 'CLOSE_PERIOD';
        l_api_version           CONSTANT NUMBER := 1.0;
        l_count                 number;
        l_open                  varchar2(1) ;
        l_val  varchar2(2000);
        l_open_prd              varchar2(15);
                BEGIN
        SAVEPOINT Close_Period_PUB;
        l_open :='N';
        -- Standard Call to check for API compatibility
                        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                              p_api_version,
                                              l_api_name,
                                      G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
        -- Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;
        /*
        Validate the validity of parameters: All Mandatory Parameters should be
        passed, API Version
        */
        IF ( P_api_version IS NULL OR
        p_sweep IS NULL OR
                 p_period_name IS NULL) THEN
                x_message_data  := 'FUN_REQUIRED_FIELDS_INCOMPLETE';
                Raise FND_API.G_EXC_ERROR;
        END IF;
        /* Check if the Period Passed is Open Period */
    if (p_trx_type_id is not null) then
                open c_open_prd1(p_period_name,p_trx_type_id);
                fetch c_open_prd1 into l_open_prd;
        if (c_open_prd1%notfound) then
                x_message_data  := 'FUN_PERIOD_NOT_OPEN';
                Raise FND_API.G_EXC_ERROR;
        End If;
        close c_open_prd1;
    else
        open c_open_prd2(p_period_name);
        fetch c_open_prd2 into l_open_prd;
        if (c_open_prd2%notfound) then
                x_message_data  := 'FUN_PERIOD_NOT_OPEN';
                Raise FND_API.G_EXC_ERROR;
        End If;
                close c_open_prd2;
    End if;
        /* if p_sweep is Yes, then p_sweep_GL_Date must not
                 null */
        If (p_sweep = 'Y') then
           If (p_sweep_GL_Date is null) then
                                /* Put the Stack Message */
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_message_data  := 'FUN_SWEEP_GL_DATE_REQ';
                Raise FND_API.G_EXC_ERROR;
           End If;
        End If;
        /* Check for open transactions */
        if (p_trx_type_id is not null) then
                open c_open_trx1(p_period_name,p_trx_type_id);
                fetch c_open_trx1 into l_count;
                if (c_open_trx1%found) then
                                l_open := 'Y';
                End If;
                close c_open_trx1;
        else
                open c_open_trx2(p_period_name) ;
                fetch c_open_trx2 into l_count;
                if (c_open_trx2%found) then
                                l_open := 'Y';
                End If;
                close c_open_trx2;
        End if;
        /* Calling Sweeping Program if p_sweep is Yes */
        if (l_open = 'Y') then
          if (p_sweep = 'Y') then
          /* submit the sweeping concurrent program */
                x_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                application => 'FUN',
                                program => 'FUNPRDSTSB',
                                description=>' Manual Intercompany Transactions Sweep',
                                start_time => '',
                                argument1=>'1.0',
                                argument2=> p_period_name,
                                argument3=> p_trx_type_id,
                                argument4=> p_sweep_GL_date,
                                argument5=> 'Y',
                                argument6=> 'Y'
                );
           Else
                x_message_data  := 'FUN_OPEN_TRXS_NOT_SWEPT';
                Raise FND_API.G_EXC_ERROR;
           end if; /* p_sweep */
        Else
                If (p_trx_type_id is not null) then
                        Update fun_period_statuses set status = 'C'
                        where trx_type_id = p_trx_type_id and
                        period_name = p_period_name
    				AND (inteco_calendar,inteco_period_type) IN
				(SELECT nvl(inteco_calendar,'~~'),nvl(inteco_period_type,'~~') FROM fun_system_options);
                Else
                        Update fun_period_statuses set status = 'C' where
                        period_name = p_period_name and status in ('O')
				AND (inteco_calendar,inteco_period_type) IN
				(SELECT nvl(inteco_calendar,'~~'),nvl(inteco_period_type,'~~') FROM fun_system_options);
                End If;
        End If; /* l_open */
        /* Commit if p_commit is not passed False */
        IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE) ) THEN
                COMMIT;
        END IF;
        if (c_open_trx1%isopen) then
                close c_open_trx1;
        end if;
        if (c_open_trx2%isopen) then
                close c_open_trx2;
        end if;
        if (c_open_prd1%isopen) then
                close c_open_trx1;
        end if;
        if (c_open_prd2%isopen) then
                close c_open_trx2;
        end if;
EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Close_Period_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                if (c_open_trx1%isopen) then
                        close c_open_trx1;
                end if;
                if (c_open_trx2%isopen) then
                        close c_open_trx2;
                end if;
                if (c_open_prd1%isopen) then
                        close c_open_prd1;
                end if;
                if (c_open_prd2%isopen) then
                        close c_open_prd2;
                end if;
        WHEN OTHERS THEN
                x_message_data     := SQLERRM;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO Close_Period_PUB;
                if (c_open_trx1%isopen) then
                        close c_open_trx1;
                end if;
                if (c_open_trx2%isopen) then
                        close c_open_trx2;
                end if;
                if (c_open_prd1%isopen) then
                        close c_open_prd1;
                end if;
                if (c_open_prd2%isopen) then
                        close c_open_prd2;
                end if;
END Close_Period;
/***********************************************
* Procedure Get_Period_Status :
*           This API Checks whether Application Module (AP, AR, GL) can close their *
*  periods. It checks whether Intercompany Period is closed and if yes then whether *
*  any Open Transactions exists for the given Period.                               *
*                                                                                                   *
***************************************************/
        PROCEDURE Get_Period_Status
        (
         p_api_version          IN NUMBER,
         p_application_id       IN NUMBER,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_message_count        OUT NOCOPY NUMBER,
         x_message_data         OUT NOCOPY VARCHAR2,
         p_period_set_name      IN VARCHAR2,
         p_period_type          IN VARCHAR2,
         p_period_name          IN VARCHAR2,
         p_ledger_id            IN NUMBER,
         p_org_id               IN NUMBER,
         x_close                OUT NOCOPY VARCHAR2
        ) IS
        Cursor c_ic_cal_defined  is select  inteco_calendar from
                         fun_system_options where
                         inteco_calendar is not null and
                         inteco_period_type is not null;
        Cursor c_ic_cal(l_period_set_name in Varchar2, l_period_type in
                Varchar2)  IS select
                         inteco_calendar from
                         fun_system_options where  inteco_calendar =
                         l_period_set_name and inteco_period_type =
                         l_period_type;
        Cursor c_ic_prd_open(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X' from
                        fun_period_statuses fps,fun_system_options fso where period_name
                        = l_prd_name and status = 'O'
				AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        Cursor c_open_trx_ap(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'  from
                        fun_trx_batches ftb, fun_trx_headers fth,
                        fun_period_statuses fps,fun_system_options fso where
                        ftb.batch_id = fth.batch_id and
                        ftb.trx_type_id=fps.trx_type_id and
                        ftb.gl_date >= fps.start_date and ftb.gl_date <=
                        fps.end_date and fps.period_name = l_prd_name and
                        fth.status not in ('NEW', 'REJECTED', 'COMPLETE')
                        and fun_tca_pkg.get_ou_id(fth.recipient_id) = p_org_id
				AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        cursor c_open_int_ap(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'  from
                        ap_invoices_interface api,
                        fun_period_statuses fps,fun_system_options fso
                        where api.source = 'GLOBAL_INTERCOMPANY' and
                        api.org_id = p_org_id and
                        api.gl_date >= fps.start_date and api.gl_date <=
                        fps.end_date and
                        fps.period_name = l_prd_name
				AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        Cursor c_open_trx_ar(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'  from
                        fun_trx_batches ftb, fun_trx_headers fth,
                        fun_period_statuses fps where ftb.batch_id = fth.batch_id and
                        ftb.trx_type_id=fps.trx_type_id and
                        ftb.gl_date >= fps.start_date and ftb.gl_date <=
                        fps.end_date and fps.period_name = l_prd_name and
                        fth.status not in ('NEW', 'REJECTED', 'COMPLETE', 'XFER_AR')
                        and fun_tca_pkg.get_ou_id(fth.initiator_id) = p_org_id);
-- Bug 9634573 modified below cursor to fetch src name from table rather than hard coded value
	cursor c_open_int_ar(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'  from
                        ra_interface_lines_all ri,
                        fun_period_statuses fps
                        where ri.batch_source_name = (SELECT name FROM
			RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = p_org_id) and
                                ri.org_id = p_org_id and
                                ri.gl_date >= fps.start_date and ri.gl_date <=
                                fps.end_date and
                                fps.period_name = l_prd_name);
        Cursor c_open_trx_gl(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X' from
                        fun_trx_batches ftb, fun_trx_headers fth,
                        fun_period_statuses fps,fun_system_options fso where ftb.batch_id = fth.batch_id and
                        ftb.gl_date >= fps.start_date and ftb.gl_date <=
                        fps.end_date and
                        ftb.trx_type_id=fps.trx_type_id and
                        fps.period_name = l_prd_name and
                        fth.status not in ('NEW', 'REJECTED', 'COMPLETE') and
                        fth.to_ledger_id = p_ledger_id
				AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        cursor c_open_int_gl(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'  from
                        gl_interface gi,
                        fun_period_statuses fps,fun_system_options fso
                        where gi.user_je_source_name = 'Global Intercompany' and
                        gi.user_je_category_name = 'Global Intercompany' and
                        gi.ledger_id = p_ledger_id and
                        gi.reference_date >= fps.start_date and gi.accounting_date <=
                        fps.end_date and
                        fps.period_name = l_prd_name
				AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        l_api_name              CONSTANT VARCHAR2(30) := 'GET_PERIOD_STATUS';
        l_api_version           CONSTANT NUMBER := 1.0;
        l_period_set_name       Varchar2(15);
        l_prd_cnt                Number;
        l_open_trx_ap_cnt        Number;
        l_open_trx_ar_cnt        Number;
        l_open_trx_gl_cnt        Number;
        l_count                  number;
        BEGIN
          -- Standard Call to check for API compatibility
                IF NOT FND_API.Compatible_API_Call (l_api_version,
                                              p_api_version,
                                              l_api_name,
                                      G_PKG_NAME)
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        -- Initialize API return status to success
                x_return_status := FND_API.G_RET_STS_SUCCESS;
        /*
        Validate the validity of parameters: All Mandatory Parameters should be passed, API Version
        */
        IF ( P_api_version IS NULL OR
                p_period_set_name IS NULL OR
                p_period_type is NULL OR
                p_application_id is NULL OR
                p_period_name IS NULL)
        THEN
                x_message_data  := 'FUN_REQUIRED_FIELDS_INCOMPLETE';
                x_return_status := FND_API.G_RET_STS_ERROR;
                Raise FND_API.G_EXC_ERROR;
         END IF;
        IF (p_application_id = 200 or p_application_id = 222) then
                        If (p_org_id is NULL) then
                                x_message_data  := 'FUN_ORG_OR_LEDGER_ID_REQ';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                Raise FND_API.G_EXC_ERROR;
                        End If;
        Elsif (p_application_id = 101) then
                        If (p_ledger_id is NULL) then
                                x_message_data  := 'FUN_ORG_OR_LEDGER_ID_REQ';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                Raise FND_API.G_EXC_ERROR;
                        End If;
         End If;
         open c_ic_cal_defined;
         fetch c_ic_cal_defined into l_period_set_name;
         if (c_ic_cal_defined%notfound) then
                x_close := 'Y';
                x_message_data  := 'FUN_IC_CALENDAR_NOT_SET';
                Close c_ic_cal_defined;
                Raise FND_API.G_EXC_ERROR;
         End If;
         Close c_ic_cal_defined;
        /*
         Check if p_period_set_name is not equal to Calendar Name set
         in  Intercompany
        */
        open c_ic_cal(p_period_set_name,p_period_type);
        fetch c_ic_cal into l_period_set_name;
        if (c_ic_cal%notfound) then
                x_close := 'Y';
                x_message_data  := 'FUN_IC_CORE_CALENDAR_DIFFERENT';
        Else
        /*
        3. <Check whether Intercompany Period is closed.>
        */
          open  c_ic_prd_open(p_period_name);
          fetch c_ic_prd_open into l_count;
          if (c_ic_prd_open%found) then
                x_close := 'N';
                x_message_data  := 'FUN_IC_PERIOD_OPEN';
                Raise FND_API.G_EXC_ERROR;
          else
                if (p_application_id = 200) then
                /* Callin Application Is AP */
                /* Check for Open transactions for AP */
                        open  c_open_trx_ap(p_period_name);
                        fetch c_open_trx_ap into l_count;
                        if (c_open_trx_ap%found) then
                                x_close := 'N';
                                x_message_data  := 'FUN_IC_TRXS_OPEN';
                                Raise FND_API.G_EXC_ERROR;
                        Else
                        /* Check for any Open transactions in AP Interface */
                                open c_open_int_ap(p_period_name);
                                fetch c_open_int_ap into l_count;
                                if (c_open_int_ap%found) then
                                        x_close:= 'N';
                                        x_message_data := 'FUN_IC_OPEN_TRXS_INTERFACE';
                                        Raise FND_API.G_EXC_ERROR;
                                else
                                        x_close := 'Y';
                                End If;
                                close c_open_int_ap;
                        End If;
                        close c_open_trx_ap;
                Elsif (p_application_id = 222) then
                /* Callin Application Is AR */
                /* Check for Open transactions for AR */
                        open  c_open_trx_ar(p_period_name);
                        fetch c_open_trx_ar into l_count;
                        if (c_open_trx_ar%found) then
                                x_close := 'N';
                                x_message_data  := 'FUN_IC_TRXS_OPEN';
                                Raise FND_API.G_EXC_ERROR;
                        Else
                        /* Check for any Open transactions in AR Interface */
                                open c_open_int_ar(p_period_name);
                                fetch c_open_int_ar into l_count;
                                if (c_open_int_ar%found) then
                                        x_close := 'N';
                                        x_message_data  := 'FUN_IC_OPEN_TRXS_INTERFACE';
                                        Raise FND_API.G_EXC_ERROR;
                                else
                                        x_close := 'Y';
                                End If;
                                close c_open_int_ar;
                        End If;
                        close c_open_trx_ar;
                Elsif (p_application_id = 101) then
                /* Callin Application Is GL */
                /* Check for Open transactions for GL */
                        open  c_open_trx_gl(p_period_name);
                        fetch c_open_trx_gl into l_count;
                        if (c_open_trx_gl%found) then
                                x_close := 'N';
                                x_message_data  := 'FUN_IC_TRXS_OPEN';
                                Raise FND_API.G_EXC_ERROR;
                        Else
                        /* Check for any Open transactions in GL Interface */
                                open c_open_int_gl(p_period_name);
                                fetch c_open_int_gl into l_count;
                                if (c_open_int_gl%found) then
                                        x_close := 'N';
                                        x_message_data  := 'FUN_IC_OPEN_TRXS_INTERFACE';
                                        Raise FND_API.G_EXC_ERROR;
                                else
                                        x_close := 'Y';
                                End If;
                                close c_open_int_gl;
                        End If;
                        close c_open_trx_gl;
                Else
                        x_message_data  := 'FUN_INVALID_APPLICATION';
                        Raise FND_API.G_EXC_ERROR;
                End If;
           End If; /* prd_open */
        close c_ic_prd_open;
        End If; /* l_period_set_name */
        if (c_ic_cal%isopen) then
                close c_ic_cal;
        end if;
        if (c_ic_prd_open%isopen) then
                close c_ic_prd_open;
        end if;
        if (c_open_trx_ap%isopen) then
                close c_open_trx_ap;
        end if;
        if (c_open_int_ap%isopen) then
                close c_open_int_ap;
        end if;
        if (c_open_trx_ar%isopen) then
                close c_open_trx_ar;
        end if;
        if (c_open_int_ar%isopen) then
                close c_open_int_ar;
        end if;
        if (c_open_trx_gl%isopen) then
                close c_open_trx_gl;
        end if;
        if (c_open_int_gl%isopen) then
                close c_open_int_gl;
        end if;
        if (c_ic_cal_defined%isopen) then
                Close c_ic_cal_defined;
        end if;
        EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                if (c_ic_cal%isopen) then
                        close c_ic_cal;
                end if;
                if (c_ic_prd_open%isopen) then
                        close c_ic_prd_open;
                end if;
                if (c_open_trx_ap%isopen) then
                        close c_open_trx_ap;
                end if;
                if (c_open_int_ap%isopen) then
                        close c_open_int_ap;
                end if;
                if (c_open_trx_ar%isopen) then
                        close c_open_trx_ar;
                end if;
                if (c_open_int_ar%isopen) then
                        close c_open_int_ar;
                end if;
                if (c_open_trx_gl%isopen) then
                        close c_open_trx_gl;
                end if;
                if (c_open_int_gl%isopen) then
                        close c_open_int_gl;
                end if;
                if (c_ic_cal_defined%isopen) then
                        Close c_ic_cal_defined;
                end if;
               WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_message_data     := SQLERRM;
                if (c_ic_cal%isopen) then
                        close c_ic_cal;
                end if;
                if (c_ic_prd_open%isopen) then
                        close c_ic_prd_open;
                end if;
                if (c_open_trx_ap%isopen) then
                        close c_open_trx_ap;
                        end if;
                if (c_open_int_ap%isopen) then
                        close c_open_int_ap;
                end if;
                if (c_open_trx_ar%isopen) then
                        close c_open_trx_ar;
                end if;
                if (c_open_int_ar%isopen) then
                        close c_open_int_ar;
                end if;
                if (c_open_trx_gl%isopen) then
                        close c_open_trx_gl;
                end if;
                if (c_open_int_gl%isopen) then
                        close c_open_int_gl;
                end if;
                if (c_ic_cal_defined%isopen) then
                        Close c_ic_cal_defined;
                end if;
        END Get_Period_Status;

/**********************************************
* Procedure sweep_partial_batches
*	Bug : 6892783
*	This API Sweeps Partially complete Batches to given period
*
************************************************/

PROCEDURE sweep_partial_batches
(     p_errbuff                       OUT NOCOPY VARCHAR2,
      p_period_name                   IN VARCHAR2,
      p_trx_type_id                   IN NUMBER,
      p_sweep_GL_date                 IN DATE
) IS

        CURSOR c_trx_id (l_batch_id in NUMBER)
        IS
        SELECT TRX_ID
        FROM FUN_TRX_HEADERS
        WHERE BATCH_ID = l_batch_id
        AND   STATUS IN ('SENT','ERROR','RECEIVED');

        l_control_date_tbl FUN_SEQ.CONTROL_DATE_TBL_TYPE;
	l_control_date_rec FUN_SEQ.CONTROL_DATE_REC_TYPE;
	l_seq_version_id        NUMBER;
	l_assignment_id         NUMBER;
	l_error_code            VARCHAR2(1000);
        l_batch_id FUN_TRX_BATCHES.BATCH_ID%TYPE;
        l_batch_number FUN_TRX_BATCHES.BATCH_NUMBER%TYPE;
        l_running_total_dr FUN_TRX_BATCHES.RUNNING_TOTAL_DR%TYPE;
        l_running_total_cr FUN_TRX_BATCHES.RUNNING_TOTAL_CR%TYPE;
        l_header_trx_id FUN_TRX_HEADERS.TRX_ID%TYPE;
        l_line_id FUN_TRX_LINES.LINE_ID%TYPE;
        l_start_date FUN_PERIOD_STATUSES.START_DATE%TYPE;
        l_end_date FUN_PERIOD_STATUSES.END_DATE%TYPE;
        sqlstmt	VARCHAR2(3000);

        TYPE c_partial_batches_type IS REF CURSOR;
        -- Bug 7115161. Added Batch Number field
	TYPE c_partial_batches_rec_type IS RECORD
		(BATCH_ID FUN_TRX_BATCHES.BATCH_ID%TYPE,
		 BATCH_NUMBER FUN_TRX_BATCHES.BATCH_NUMBER%TYPE);

	c_partial_batches c_partial_batches_type;
	l_partial_batch c_partial_batches_rec_type;

   ------Bug#: 	7129198 --- START
   l_sqlstmt VARCHAR2(3000);

   TYPE c_trx_attachment IS REF CURSOR;
   c_trx_attm c_trx_attachment;

-- Bug 9756187 Start
   l_sqlstmt_batch VARCHAR2(3000);

   TYPE c_batch_attachment IS REF CURSOR;
   c_batch_attm c_batch_attachment;

l_batch_ATTACHED_DOCUMENT_ID			  FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
l_batch_DOCUMENT_ID				  FND_ATTACHED_DOCUMENTS.DOCUMENT_ID%TYPE;

-- Bug 9756187 end

   icx_language VARCHAR2(100);

   TYPE c_trx_attachment_rec_type IS RECORD
	(ROWID					  VARCHAR2(4000),
	 ATTACHED_DOCUMENT_ID			  FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE,
	 DOCUMENT_ID				  FND_ATTACHED_DOCUMENTS.DOCUMENT_ID%TYPE,
	 SEQ_NUM				  FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE,
	 ENTITY_NAME				  FND_ATTACHED_DOCUMENTS.ENTITY_NAME%TYPE,
	 COLUMN1				  FND_ATTACHED_DOCUMENTS.COLUMN1%TYPE,
	 PK1_VALUE				  FND_ATTACHED_DOCUMENTS.PK1_VALUE%TYPE,
	 PK2_VALUE				  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE,
	 PK3_VALUE				  FND_ATTACHED_DOCUMENTS.PK3_VALUE%TYPE,
	 PK4_VALUE				  FND_ATTACHED_DOCUMENTS.PK4_VALUE%TYPE,
	 PK5_VALUE				  FND_ATTACHED_DOCUMENTS.PK5_VALUE%TYPE,
	 AUTOMATICALLY_ADDED_FLAG		  FND_ATTACHED_DOCUMENTS.AUTOMATICALLY_ADDED_FLAG%TYPE,
	 REQUEST_ID				  FND_ATTACHED_DOCUMENTS.REQUEST_ID%TYPE,
	 PROGRAM_APPLICATION_ID			  FND_ATTACHED_DOCUMENTS.PROGRAM_APPLICATION_ID%TYPE,
	 PROGRAM_ID				  FND_ATTACHED_DOCUMENTS.PROGRAM_ID%TYPE,
	 PROGRAM_UPDATE_DATE                      FND_ATTACHED_DOCUMENTS.PROGRAM_UPDATE_DATE%TYPE,
	 ATTRIBUTE_CATEGORY			  FND_ATTACHED_DOCUMENTS.ATTRIBUTE_CATEGORY%TYPE,
	 ATTRIBUTE1				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE1%TYPE,
	 ATTRIBUTE2				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE2%TYPE,
	 ATTRIBUTE3				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE3%TYPE,
	 ATTRIBUTE4				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE4%TYPE,
	 ATTRIBUTE5				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE5%TYPE,
	 ATTRIBUTE6				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE6%TYPE,
	 ATTRIBUTE7				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE7%TYPE,
	 ATTRIBUTE8				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE8%TYPE,
	 ATTRIBUTE9				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE9%TYPE,
	 ATTRIBUTE10				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE10%TYPE,
	 ATTRIBUTE11				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE11%TYPE,
	 ATTRIBUTE12				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE12%TYPE,
	 ATTRIBUTE13				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE13%TYPE,
	 ATTRIBUTE14				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE14%TYPE,
	 ATTRIBUTE15				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE15%TYPE,
         -------------------------------------
         DATATYPE_ID				  FND_DOCUMENTS.DATATYPE_ID%TYPE,
	 CATEGORY_ID				  FND_DOCUMENTS.CATEGORY_ID%TYPE,
	 SECURITY_TYPE				  FND_DOCUMENTS.SECURITY_TYPE%TYPE,
	 SECURITY_ID				  FND_DOCUMENTS.SECURITY_ID%TYPE,
	 PUBLISH_FLAG				  FND_DOCUMENTS.PUBLISH_FLAG%TYPE,
	 IMAGE_TYPE				  FND_DOCUMENTS.IMAGE_TYPE%TYPE,
	 STORAGE_TYPE				  FND_DOCUMENTS.STORAGE_TYPE%TYPE,
	 USAGE_TYPE				  FND_DOCUMENTS.USAGE_TYPE%TYPE,
	 START_DATE_ACTIVE			  FND_DOCUMENTS.START_DATE_ACTIVE%TYPE,
	 END_DATE_ACTIVE			  FND_DOCUMENTS.END_DATE_ACTIVE%TYPE,
	 ---------------------------------------
	 l_LANGUAGE				  fnd_documents_tl.LANGUAGE%TYPE,
	 DESCRIPTION				  fnd_documents_tl.DESCRIPTION%TYPE,
	 FILE_NAME				  fnd_documents.FILE_NAME%TYPE,
	 MEDIA_ID				  fnd_documents.MEDIA_ID%TYPE,    -- IN OUT NOCOPY
	 DOC_ATTRIBUTE_CATEGORY			  fnd_documents_tl.DOC_ATTRIBUTE_CATEGORY%TYPE,
	 DOC_ATTRIBUTE1				  fnd_documents_tl.DOC_ATTRIBUTE1%TYPE,
	 DOC_ATTRIBUTE2				  fnd_documents_tl.DOC_ATTRIBUTE2%TYPE,
	 DOC_ATTRIBUTE3				  fnd_documents_tl.DOC_ATTRIBUTE3%TYPE,
	 DOC_ATTRIBUTE4				  fnd_documents_tl.DOC_ATTRIBUTE4%TYPE,
	 DOC_ATTRIBUTE5				  fnd_documents_tl.DOC_ATTRIBUTE5%TYPE,
	 DOC_ATTRIBUTE6				  fnd_documents_tl.DOC_ATTRIBUTE6%TYPE,
	 DOC_ATTRIBUTE7				  fnd_documents_tl.DOC_ATTRIBUTE7%TYPE,
	 DOC_ATTRIBUTE8				  fnd_documents_tl.DOC_ATTRIBUTE8%TYPE,
	 DOC_ATTRIBUTE9				  fnd_documents_tl.DOC_ATTRIBUTE9%TYPE,
	 DOC_ATTRIBUTE10			  fnd_documents_tl.DOC_ATTRIBUTE10%TYPE,
	 DOC_ATTRIBUTE11			  fnd_documents_tl.DOC_ATTRIBUTE11%TYPE,
	 DOC_ATTRIBUTE12			  fnd_documents_tl.DOC_ATTRIBUTE12%TYPE,
	 DOC_ATTRIBUTE13			  fnd_documents_tl.DOC_ATTRIBUTE13%TYPE,
	 DOC_ATTRIBUTE14			  fnd_documents_tl.DOC_ATTRIBUTE14%TYPE,
	 DOC_ATTRIBUTE15			  fnd_documents_tl.DOC_ATTRIBUTE15%TYPE,
	 URL					  FND_DOCUMENTS.URL%TYPE,
	 TITLE					  fnd_documents_tl.TITLE%TYPE
	 );

-- Bug 9756187 Start

TYPE c_batch_attachment_rec_type IS RECORD
	(ROWID					  VARCHAR2(4000),
 creation_date FND_ATTACHED_DOCUMENTS.creation_date%TYPE,
   created_by FND_ATTACHED_DOCUMENTS.created_by%TYPE,
	 SEQ_NUM				  FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE,
	 ENTITY_NAME				  FND_ATTACHED_DOCUMENTS.ENTITY_NAME%TYPE,
	 COLUMN1				  FND_ATTACHED_DOCUMENTS.COLUMN1%TYPE,
	 PK1_VALUE				  FND_ATTACHED_DOCUMENTS.PK1_VALUE%TYPE,
	 PK2_VALUE				  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE,
	 PK3_VALUE				  FND_ATTACHED_DOCUMENTS.PK3_VALUE%TYPE,
	 PK4_VALUE				  FND_ATTACHED_DOCUMENTS.PK4_VALUE%TYPE,
	 PK5_VALUE				  FND_ATTACHED_DOCUMENTS.PK5_VALUE%TYPE,
	 AUTOMATICALLY_ADDED_FLAG		  FND_ATTACHED_DOCUMENTS.AUTOMATICALLY_ADDED_FLAG%TYPE,
	 REQUEST_ID				  FND_ATTACHED_DOCUMENTS.REQUEST_ID%TYPE,
	 PROGRAM_APPLICATION_ID			  FND_ATTACHED_DOCUMENTS.PROGRAM_APPLICATION_ID%TYPE,
	 PROGRAM_ID				  FND_ATTACHED_DOCUMENTS.PROGRAM_ID%TYPE,
	 PROGRAM_UPDATE_DATE                      FND_ATTACHED_DOCUMENTS.PROGRAM_UPDATE_DATE%TYPE,
	 ATTRIBUTE_CATEGORY			  FND_ATTACHED_DOCUMENTS.ATTRIBUTE_CATEGORY%TYPE,
	 ATTRIBUTE1				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE1%TYPE,
	 ATTRIBUTE2				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE2%TYPE,
	 ATTRIBUTE3				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE3%TYPE,
	 ATTRIBUTE4				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE4%TYPE,
	 ATTRIBUTE5				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE5%TYPE,
	 ATTRIBUTE6				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE6%TYPE,
	 ATTRIBUTE7				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE7%TYPE,
	 ATTRIBUTE8				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE8%TYPE,
	 ATTRIBUTE9				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE9%TYPE,
	 ATTRIBUTE10				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE10%TYPE,
	 ATTRIBUTE11				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE11%TYPE,
	 ATTRIBUTE12				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE12%TYPE,
	 ATTRIBUTE13				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE13%TYPE,
	 ATTRIBUTE14				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE14%TYPE,
	 ATTRIBUTE15				  FND_ATTACHED_DOCUMENTS.ATTRIBUTE15%TYPE,
         -------------------------------------
         DATATYPE_ID				  FND_DOCUMENTS.DATATYPE_ID%TYPE,
	 CATEGORY_ID				  FND_DOCUMENTS.CATEGORY_ID%TYPE,
	 SECURITY_TYPE				  FND_DOCUMENTS.SECURITY_TYPE%TYPE,
	 SECURITY_ID				  FND_DOCUMENTS.SECURITY_ID%TYPE,
	 PUBLISH_FLAG				  FND_DOCUMENTS.PUBLISH_FLAG%TYPE,
	 IMAGE_TYPE				  FND_DOCUMENTS.IMAGE_TYPE%TYPE,
	 STORAGE_TYPE				  FND_DOCUMENTS.STORAGE_TYPE%TYPE,
	 USAGE_TYPE				  FND_DOCUMENTS.USAGE_TYPE%TYPE,
	 START_DATE_ACTIVE			  FND_DOCUMENTS.START_DATE_ACTIVE%TYPE,
	 END_DATE_ACTIVE			  FND_DOCUMENTS.END_DATE_ACTIVE%TYPE,
	 ---------------------------------------
	 l_LANGUAGE				  fnd_documents_tl.LANGUAGE%TYPE,
	 DESCRIPTION				  fnd_documents_tl.DESCRIPTION%TYPE,
	 FILE_NAME				  fnd_documents.FILE_NAME%TYPE,
	 MEDIA_ID				  fnd_documents.MEDIA_ID%TYPE,    -- IN OUT NOCOPY
	 DOC_ATTRIBUTE_CATEGORY			  fnd_documents_tl.DOC_ATTRIBUTE_CATEGORY%TYPE,
	 DOC_ATTRIBUTE1				  fnd_documents_tl.DOC_ATTRIBUTE1%TYPE,
	 DOC_ATTRIBUTE2				  fnd_documents_tl.DOC_ATTRIBUTE2%TYPE,
	 DOC_ATTRIBUTE3				  fnd_documents_tl.DOC_ATTRIBUTE3%TYPE,
	 DOC_ATTRIBUTE4				  fnd_documents_tl.DOC_ATTRIBUTE4%TYPE,
	 DOC_ATTRIBUTE5				  fnd_documents_tl.DOC_ATTRIBUTE5%TYPE,
	 DOC_ATTRIBUTE6				  fnd_documents_tl.DOC_ATTRIBUTE6%TYPE,
	 DOC_ATTRIBUTE7				  fnd_documents_tl.DOC_ATTRIBUTE7%TYPE,
	 DOC_ATTRIBUTE8				  fnd_documents_tl.DOC_ATTRIBUTE8%TYPE,
	 DOC_ATTRIBUTE9				  fnd_documents_tl.DOC_ATTRIBUTE9%TYPE,
	 DOC_ATTRIBUTE10			  fnd_documents_tl.DOC_ATTRIBUTE10%TYPE,
	 DOC_ATTRIBUTE11			  fnd_documents_tl.DOC_ATTRIBUTE11%TYPE,
	 DOC_ATTRIBUTE12			  fnd_documents_tl.DOC_ATTRIBUTE12%TYPE,
	 DOC_ATTRIBUTE13			  fnd_documents_tl.DOC_ATTRIBUTE13%TYPE,
	 DOC_ATTRIBUTE14			  fnd_documents_tl.DOC_ATTRIBUTE14%TYPE,
	 DOC_ATTRIBUTE15			  fnd_documents_tl.DOC_ATTRIBUTE15%TYPE,
   URL					  FND_DOCUMENTS.URL%TYPE,
	 TITLE					  fnd_documents_tl.TITLE%TYPE
	 );

-- Bug 9756187 End

   l_attchmt_rec_type c_trx_attachment_rec_type;
   l_batch_attchmt_rec_type c_batch_attachment_rec_type;

   ------Bug#: 	7129198 --- END
BEGIN

	IF ( p_sweep_GL_Date IS NULL OR
             p_period_name IS NULL) THEN
             	p_errbuff  := 'Required Fields not Passed';
                Print('REQUIRED FIELDS NOT PASSED');
                Raise FND_API.G_EXC_ERROR;
        END IF;


	IF (p_trx_type_id is NOT NULL) THEN

		SELECT START_DATE
		INTO l_start_date
		FROM FUN_PERIOD_STATUSES FPS,FUN_SYSTEM_OPTIONS FSO
		WHERE FPS.PERIOD_NAME =  p_period_name
		AND FPS.TRX_TYPE_ID = p_trx_type_id
		AND FPS.INTECO_CALENDAR=NVL(FSO.INTECO_CALENDAR, '~~')
		AND FPS.INTECO_PERIOD_TYPE=NVL(FSO.INTECO_PERIOD_TYPE,'~~');

		SELECT END_DATE
		INTO l_end_date
		FROM FUN_PERIOD_STATUSES FPS,FUN_SYSTEM_OPTIONS FSO
		WHERE FPS.PERIOD_NAME = p_period_name
		AND FPS.TRX_TYPE_ID = p_trx_type_id
		AND FPS.INTECO_CALENDAR=NVL(FSO.INTECO_CALENDAR,'~~')
		AND FPS.INTECO_PERIOD_TYPE=NVL(FSO.INTECO_PERIOD_TYPE,'~~');

		--Bug 7115161. Changed the Query to fetch the batch number also

		sqlstmt := 'SELECT BATCH_ID, BATCH_NUMBER
			FROM FUN_TRX_BATCHES
  			WHERE GL_DATE >= ''' || l_start_date || '''
			AND GL_DATE <= ''' || l_end_date || '''
			AND TRX_TYPE_ID = ''' || p_trx_type_id || '''
        		AND BATCH_ID IN
        			(SELECT BATCH_ID
        			FROM FUN_TRX_HEADERS
        			WHERE STATUS IN (''SENT'',''ERROR'',''RECEIVED''))
        		AND STATUS NOT IN (''COMPLETE'', ''NEW'')';

	ELSE
		sqlstmt := 'SELECT BATCH_ID, BATCH_NUMBER
			FROM FUN_TRX_BATCHES
			WHERE GL_DATE >=
				(SELECT DISTINCT START_DATE
				FROM FUN_PERIOD_STATUSES FPS,FUN_SYSTEM_OPTIONS FSO
				WHERE FPS.PERIOD_NAME = ''' || p_period_name || '''
				AND FPS.INTECO_CALENDAR=NVL(FSO.INTECO_CALENDAR,''~~'')
				AND FPS.INTECO_PERIOD_TYPE=NVL(FSO.INTECO_PERIOD_TYPE,''~~''))
			AND GL_DATE <=
				(SELECT DISTINCT END_DATE
				FROM FUN_PERIOD_STATUSES FPS,FUN_SYSTEM_OPTIONS FSO
				WHERE FPS.PERIOD_NAME = ''' || p_period_name || '''
				AND FPS.INTECO_CALENDAR=NVL(FSO.INTECO_CALENDAR,''~~'')
				AND FPS.INTECO_PERIOD_TYPE=NVL(FSO.INTECO_PERIOD_TYPE,''~~''))
			AND TRX_TYPE_ID IN
				(SELECT TRX_TYPE_ID
				FROM FUN_PERIOD_STATUSES FPS,FUN_SYSTEM_OPTIONS FSO
				WHERE FPS.PERIOD_NAME = ''' || p_period_name || '''
				AND FPS.INTECO_CALENDAR=NVL(FSO.INTECO_CALENDAR,''~~'')
				AND FPS.INTECO_PERIOD_TYPE=NVL(FSO.INTECO_PERIOD_TYPE,''~~''))
			AND BATCH_ID IN
				(SELECT BATCH_ID
				FROM FUN_TRX_HEADERS
				WHERE STATUS IN (''SENT'',''ERROR'',''RECEIVED''))
			AND STATUS NOT IN (''COMPLETE'', ''NEW'');';
	END IF;


	l_control_date_tbl := FUN_SEQ.CONTROL_DATE_TBL_TYPE();
    	l_control_date_tbl.EXTEND(1);
    	l_control_date_rec.date_type := 'CREATION_DATE';
	l_control_date_rec.date_value := sysdate;
	l_control_date_tbl(1) := l_control_date_rec;

  	OPEN c_partial_batches FOR sqlstmt;
	LOOP

		FETCH	c_partial_batches
		INTO	l_partial_batch;
		EXIT WHEN c_partial_batches%NOTFOUND;



		l_running_total_dr := 0;
		l_running_total_cr := 0;

		--Fecthing the New Batch_id
		SELECT FUN_TRX_BATCHES_S.nextval INTO l_batch_id FROM DUAL;

		--Fetching the New Batch Number
		FUN_SEQ.GET_SEQUENCE_NUMBER('INTERCOMPANY_BATCH_SOURCE',
		                            'LOCAL',
		                            435,
		                            'FUN_TRX_BATCHES',
		                            'CREATION',
		                            null,
		                            l_control_date_tbl,
		                            'N',
		                            l_seq_version_id,
		                            l_batch_number,
		                            l_assignment_id,
                              		    l_error_code);

		-- Bug 7115161. Populating the Old Batch number to the Notes field
		INSERT INTO FUN_TRX_BATCHES
			(BATCH_ID,
			 BATCH_NUMBER,
			 GL_DATE,
			 STATUS,
			 NOTE,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 INITIATOR_ID,
			 FROM_LE_ID,
			 FROM_LEDGER_ID,
			 CONTROL_TOTAL,
			 RUNNING_TOTAL_CR,
			 RUNNING_TOTAL_DR,
			 CURRENCY_CODE,
			 EXCHANGE_RATE_TYPE,
			 DESCRIPTION,
			 TRX_TYPE_ID,
			 TRX_TYPE_CODE,
			 BATCH_DATE,
			 REJECT_ALLOW_FLAG,
			 ORIGINAL_BATCH_ID,
			 REVERSED_BATCH_ID,
			 FROM_RECURRING_BATCH_ID,
			 INITIATOR_SOURCE,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 ATTRIBUTE_CATEGORY,
			 AUTO_PRORATION_FLAG)
		 SELECT  l_batch_id,
			 l_batch_number,
			 p_sweep_GL_date,
			 'NEW',
			 'Original Batch: ' || l_partial_batch.BATCH_NUMBER,
			 fnd_global.user_id,
			 sysdate,
			 fnd_global.user_id,
			 sysdate,
			 fnd_global.login_id,
			 INITIATOR_ID,
			 FROM_LE_ID,
			 FROM_LEDGER_ID,
			 CONTROL_TOTAL,
			 RUNNING_TOTAL_CR,
			 RUNNING_TOTAL_DR,
			 CURRENCY_CODE,
			 EXCHANGE_RATE_TYPE,
			 DESCRIPTION,
			 TRX_TYPE_ID,
			 TRX_TYPE_CODE,
			 BATCH_DATE,
			 REJECT_ALLOW_FLAG,
			 ORIGINAL_BATCH_ID,
			 REVERSED_BATCH_ID,
			 FROM_RECURRING_BATCH_ID,
			 INITIATOR_SOURCE,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 ATTRIBUTE_CATEGORY,
			 AUTO_PRORATION_FLAG
	 	 FROM FUN_TRX_BATCHES
    		 WHERE BATCH_ID = l_partial_batch.BATCH_ID;

    		 FOR l_trx_id in c_trx_id(l_partial_batch.BATCH_ID)
    		 LOOP
    		 	l_header_trx_id := 0;
    		 	l_line_id := 0;
        		SELECT FUN_TRX_HEADERS_S.nextval INTO l_header_trx_id FROM DUAL;
    		 	SELECT FUN_TRX_LINES_S.nextval INTO l_line_id FROM DUAL;

			 INSERT INTO FUN_TRX_HEADERS
				(TRX_ID,
				BATCH_ID,
				STATUS,
				INIT_WF_KEY,
				RECI_WF_KEY,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				TRX_NUMBER,
				INITIATOR_ID,
				RECIPIENT_ID,
				TO_LE_ID,
				TO_LEDGER_ID,
				INIT_AMOUNT_CR,
				INIT_AMOUNT_DR,
				RECI_AMOUNT_CR,
				RECI_AMOUNT_DR,
				AR_INVOICE_NUMBER,
				INVOICE_FLAG,
				APPROVER_ID,
				APPROVAL_DATE,
				ORIGINAL_TRX_ID,
				REVERSED_TRX_ID,
				FROM_RECURRING_TRX_ID,
				INITIATOR_INSTANCE_FLAG,
				RECIPIENT_INSTANCE_FLAG,
				REJECT_REASON,
				DESCRIPTION,
				ATTRIBUTE1,
				ATTRIBUTE2,
				ATTRIBUTE3,
				ATTRIBUTE4,
				ATTRIBUTE5,
				ATTRIBUTE6,
				ATTRIBUTE7,
				ATTRIBUTE8,
				ATTRIBUTE9,
				ATTRIBUTE10,
				ATTRIBUTE11,
				ATTRIBUTE12,
				ATTRIBUTE13,
				ATTRIBUTE14,
				ATTRIBUTE15,
				ATTRIBUTE_CATEGORY)
			SELECT  l_header_trx_id,
				l_batch_id,
				'NEW',
				NULL,
				NULL,
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
			 	fnd_global.login_id,
				TRX_NUMBER,
				INITIATOR_ID,
				RECIPIENT_ID,
				TO_LE_ID,
				TO_LEDGER_ID,
				INIT_AMOUNT_CR,
				INIT_AMOUNT_DR,
				RECI_AMOUNT_CR,
				RECI_AMOUNT_DR,
				AR_INVOICE_NUMBER,
				INVOICE_FLAG,
				APPROVER_ID,
				APPROVAL_DATE,
				ORIGINAL_TRX_ID,
				REVERSED_TRX_ID,
				FROM_RECURRING_TRX_ID,
				INITIATOR_INSTANCE_FLAG,
				RECIPIENT_INSTANCE_FLAG,
				REJECT_REASON,
				DESCRIPTION,
				ATTRIBUTE1,
				ATTRIBUTE2,
				ATTRIBUTE3,
				ATTRIBUTE4,
				ATTRIBUTE5,
				ATTRIBUTE6,
				ATTRIBUTE7,
				ATTRIBUTE8,
				ATTRIBUTE9,
				ATTRIBUTE10,
				ATTRIBUTE11,
				ATTRIBUTE12,
				ATTRIBUTE13,
				ATTRIBUTE14,
				ATTRIBUTE15,
				ATTRIBUTE_CATEGORY
			FROM FUN_TRX_HEADERS
			WHERE TRX_ID = l_trx_id.TRX_ID;

	   	        ------Bug#: 	7129198 --- START

			fnd_profile.get(FND_CONST.ICX_LANGUAGE,icx_language);
			SELECT language_code INTO icx_language FROM fnd_languages WHERE NLS_LANGUAGE=icx_language;

			l_sqlstmt:=
			'SELECT
			    atth.ROWID,
			    atth.ATTACHED_DOCUMENT_ID,
			    atth.DOCUMENT_ID,
			    atth.SEQ_NUM,
			    atth.ENTITY_NAME,
			    atth.COLUMN1,
			    atth.PK1_VALUE,
			    atth.PK2_VALUE,
			    atth.PK3_VALUE,
			    atth.PK4_VALUE,
			    atth.PK5_VALUE,
			    atth.AUTOMATICALLY_ADDED_FLAG,
			    atth.REQUEST_ID,
			    atth.PROGRAM_APPLICATION_ID,
			    atth.PROGRAM_ID,
			    atth.PROGRAM_UPDATE_DATE,
			    atth.ATTRIBUTE_CATEGORY,
			    atth.ATTRIBUTE1,
			    atth.ATTRIBUTE2,
			    atth.ATTRIBUTE3,
			    atth.ATTRIBUTE4,
			    atth.ATTRIBUTE5,
			    atth.ATTRIBUTE6,
			    atth.ATTRIBUTE7,
			    atth.ATTRIBUTE8,
			    atth.ATTRIBUTE9,
			    atth.ATTRIBUTE10,
			    atth.ATTRIBUTE11,
			    atth.ATTRIBUTE12,
			    atth.ATTRIBUTE13,
			    atth.ATTRIBUTE14,
			    atth.ATTRIBUTE15,

			    docs.DATATYPE_ID,
			    docs.CATEGORY_ID,
			    docs.SECURITY_TYPE,
			    docs.SECURITY_ID,
			    docs.PUBLISH_FLAG,
			    docs.IMAGE_TYPE,
			    docs.STORAGE_TYPE,
			    docs.USAGE_TYPE,
			    docs.START_DATE_ACTIVE,
			    docs.END_DATE_ACTIVE,

			    tl.LANGUAGE,
			    tl.DESCRIPTION,
			    docs.FILE_NAME,
			    docs.MEDIA_ID,
			    tl.DOC_ATTRIBUTE_CATEGORY,
			    tl.DOC_ATTRIBUTE1,
			    tl.DOC_ATTRIBUTE2,
			    tl.DOC_ATTRIBUTE3,
			    tl.DOC_ATTRIBUTE4,
			    tl.DOC_ATTRIBUTE5,
			    tl.DOC_ATTRIBUTE6,
			    tl.DOC_ATTRIBUTE7,
			    tl.DOC_ATTRIBUTE8,
			    tl.DOC_ATTRIBUTE9,
			    tl.DOC_ATTRIBUTE10,
			    tl.DOC_ATTRIBUTE11,
			    tl.DOC_ATTRIBUTE12,
			    tl.DOC_ATTRIBUTE13,
			    tl.DOC_ATTRIBUTE14,
			    tl.DOC_ATTRIBUTE15,
			    docs.URL,
			    tl.TITLE

			from fnd_documents docs,
			     FND_ATTACHED_DOCUMENTS atth,
			     fnd_documents_tl tl

			where entity_name = ''FUN_TRX_HEADERS''
			      and tl.LANGUAGE=''' || icx_language || '''
			      and pk1_value=''' || l_trx_id.TRX_ID || '''
			      and docs.document_id = atth.document_id
			      and tl.document_id = atth.document_id';


			OPEN c_trx_attm FOR l_sqlstmt;
			LOOP
			  FETCH	c_trx_attm INTO l_attchmt_rec_type;
			  EXIT WHEN c_trx_attm%NOTFOUND;

			  fnd_attached_documents_pkg.Update_Row(
			         X_Rowid    => l_attchmt_rec_type.ROWID,
				 X_attached_document_id   => l_attchmt_rec_type.ATTACHED_DOCUMENT_ID,
				 X_document_id        => l_attchmt_rec_type.DOCUMENT_ID,
				 X_last_update_date   => sysdate,
				 X_last_updated_by    => FND_GLOBAL.USER_ID,
				 X_last_update_login   => FND_GLOBAL.USER_ID,
				 X_seq_num     => l_attchmt_rec_type.SEQ_NUM,
				 X_entity_name => l_attchmt_rec_type.ENTITY_NAME,
				 X_column1      => l_attchmt_rec_type.COLUMN1,
				 X_pk1_value     => l_header_trx_id,
				 X_pk2_value   => l_attchmt_rec_type.PK2_VALUE,
				 X_pk3_value   => l_attchmt_rec_type.PK3_VALUE,
				 X_pk4_value   => l_attchmt_rec_type.PK4_VALUE,
				 X_pk5_value   => l_attchmt_rec_type.PK5_VALUE,
				 X_automatically_added_flag   => l_attchmt_rec_type.AUTOMATICALLY_ADDED_FLAG,
				 X_request_id     => l_attchmt_rec_type.REQUEST_ID,
				 X_program_application_id => l_attchmt_rec_type.PROGRAM_APPLICATION_ID,
				 X_program_id  => l_attchmt_rec_type.PROGRAM_ID,
				 X_program_update_date => l_attchmt_rec_type.PROGRAM_UPDATE_DATE,
				 X_Attribute_Category => l_attchmt_rec_type.ATTRIBUTE_CATEGORY,
				 X_Attribute1 => l_attchmt_rec_type.ATTRIBUTE1,
				 X_Attribute2 => l_attchmt_rec_type.ATTRIBUTE2,
				 X_Attribute3 => l_attchmt_rec_type.ATTRIBUTE3,
				 X_Attribute4 => l_attchmt_rec_type.ATTRIBUTE4,
				 X_Attribute5 => l_attchmt_rec_type.ATTRIBUTE5,
				 X_Attribute6 => l_attchmt_rec_type.ATTRIBUTE6,
				 X_Attribute7 => l_attchmt_rec_type.ATTRIBUTE7,
				 X_Attribute8 => l_attchmt_rec_type.ATTRIBUTE8,
				 X_Attribute9 => l_attchmt_rec_type.ATTRIBUTE9,
				 X_Attribute10 => l_attchmt_rec_type.ATTRIBUTE10,
				 X_Attribute11 => l_attchmt_rec_type.ATTRIBUTE11,
				 X_Attribute12 => l_attchmt_rec_type.ATTRIBUTE12,
				 X_Attribute13 => l_attchmt_rec_type.ATTRIBUTE13,
				 X_Attribute14 => l_attchmt_rec_type.ATTRIBUTE14,
				 X_Attribute15 => l_attchmt_rec_type.ATTRIBUTE15,


			         /*  columns necessary for creating a document on the fly */
				 X_datatype_id                  => l_attchmt_rec_type.DATATYPE_ID,
				 X_category_id                  => l_attchmt_rec_type.CATEGORY_ID,
				 X_security_type                => l_attchmt_rec_type.SECURITY_TYPE,
				 X_security_id                => l_attchmt_rec_type.SECURITY_ID,
				 X_publish_flag                 => l_attchmt_rec_type.PUBLISH_FLAG,
				 X_image_type                   => l_attchmt_rec_type.IMAGE_TYPE,
				 X_storage_type                => l_attchmt_rec_type.STORAGE_TYPE,
				 X_usage_type                => l_attchmt_rec_type.USAGE_TYPE,
				 X_start_date_active           => l_attchmt_rec_type.START_DATE_ACTIVE,
				 X_end_date_active             => l_attchmt_rec_type.END_DATE_ACTIVE,
				 X_language                     => l_attchmt_rec_type.l_LANGUAGE,
				 X_description                  => l_attchmt_rec_type.DESCRIPTION,
				 X_file_name                    => l_attchmt_rec_type.FILE_NAME,
				 X_media_id                     => l_attchmt_rec_type.MEDIA_ID,
				 X_doc_Attribute_Category       => l_attchmt_rec_type.DOC_ATTRIBUTE_CATEGORY,
				 X_doc_Attribute1               => l_attchmt_rec_type.DOC_ATTRIBUTE1,
				 X_doc_Attribute2               => l_attchmt_rec_type.DOC_ATTRIBUTE2,
				 X_doc_Attribute3               => l_attchmt_rec_type.DOC_ATTRIBUTE3,
				 X_doc_Attribute4               => l_attchmt_rec_type.DOC_ATTRIBUTE4,
				 X_doc_Attribute5              => l_attchmt_rec_type.DOC_ATTRIBUTE5,
				 X_doc_Attribute6               => l_attchmt_rec_type.DOC_ATTRIBUTE6,
				 X_doc_Attribute7               => l_attchmt_rec_type.DOC_ATTRIBUTE7,
				 X_doc_Attribute8               => l_attchmt_rec_type.DOC_ATTRIBUTE8,
				 X_doc_Attribute9               => l_attchmt_rec_type.DOC_ATTRIBUTE9,
				 X_doc_Attribute10              => l_attchmt_rec_type.DOC_ATTRIBUTE10,
				 X_doc_Attribute11              => l_attchmt_rec_type.DOC_ATTRIBUTE11,
				 X_doc_Attribute12              => l_attchmt_rec_type.DOC_ATTRIBUTE12,
				 X_doc_Attribute13              => l_attchmt_rec_type.DOC_ATTRIBUTE13,
				 X_doc_Attribute14              => l_attchmt_rec_type.DOC_ATTRIBUTE14,
				 X_doc_Attribute15              => l_attchmt_rec_type.DOC_ATTRIBUTE15,
				 X_url                          => l_attchmt_rec_type.URL,
				 X_title			=> l_attchmt_rec_type.TITLE
				);

			END LOOP;
			CLOSE c_trx_attm;


			INSERT INTO FUN_TRX_LINES
				(LINE_ID,
				TRX_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				LINE_NUMBER,
				LINE_TYPE_FLAG,
				INIT_AMOUNT_CR,
				INIT_AMOUNT_DR,
				RECI_AMOUNT_CR,
				RECI_AMOUNT_DR,
				DESCRIPTION)
			SELECT  l_line_id,
				l_header_trx_id,
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
			 	fnd_global.login_id,
				LINE_NUMBER,
				LINE_TYPE_FLAG,
				INIT_AMOUNT_CR,
				INIT_AMOUNT_DR,
				RECI_AMOUNT_CR,
				RECI_AMOUNT_DR,
				DESCRIPTION
			FROM FUN_TRX_LINES
			WHERE TRX_ID = l_trx_id.TRX_ID;

			INSERT INTO FUN_DIST_LINES
				(TRX_ID,
                		DIST_ID,
                		LINE_ID,
                		CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
                		LAST_UPDATE_LOGIN,
                		DIST_NUMBER,
                		PARTY_ID,
                		PARTY_TYPE_FLAG,
                		DIST_TYPE_FLAG,
                		BATCH_DIST_ID,
                		AMOUNT_CR,
                		AMOUNT_DR,
                		CCID,
                		DESCRIPTION,
                		AUTO_GENERATE_FLAG,
                		ATTRIBUTE1,
                		ATTRIBUTE2,
                		ATTRIBUTE3,
                		ATTRIBUTE4,
                		ATTRIBUTE5,
                		ATTRIBUTE6,
                		ATTRIBUTE7,
                		ATTRIBUTE8,
                		ATTRIBUTE9,
                		ATTRIBUTE10,
                		ATTRIBUTE11,
                		ATTRIBUTE12,
                		ATTRIBUTE13,
                		ATTRIBUTE14,
                		ATTRIBUTE15,
                		ATTRIBUTE_CATEGORY)
			SELECT  l_header_trx_id,
				FUN_DIST_LINES_S.nextval,
				l_line_id,
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
			 	fnd_global.login_id,
                		DIST_NUMBER,
                		PARTY_ID,
                		PARTY_TYPE_FLAG,
                		DIST_TYPE_FLAG,
                		BATCH_DIST_ID,
                		AMOUNT_CR,
                		AMOUNT_DR,
                		CCID,
                		DESCRIPTION,
                		AUTO_GENERATE_FLAG,
                		ATTRIBUTE1,
                		ATTRIBUTE2,
                		ATTRIBUTE3,
                		ATTRIBUTE4,
                		ATTRIBUTE5,
                		ATTRIBUTE6,
                		ATTRIBUTE7,
                		ATTRIBUTE8,
                		ATTRIBUTE9,
                		ATTRIBUTE10,
                		ATTRIBUTE11,
                		ATTRIBUTE12,
                		ATTRIBUTE13,
                		ATTRIBUTE14,
                		ATTRIBUTE15,
                		ATTRIBUTE_CATEGORY
			FROM FUN_DIST_LINES
			WHERE TRX_ID = l_trx_id.TRX_ID;

    		END LOOP;


	   	        ------Bug#: 	7129198 --- END
-- Bug 9756187 Start

l_sqlstmt_batch:=
			'SELECT
			    atth.ROWID,
          atth.creation_date,
          atth.created_by,
			    atth.SEQ_NUM,
			    atth.ENTITY_NAME,
			    atth.COLUMN1,
			    atth.PK1_VALUE,
			    atth.PK2_VALUE,
			    atth.PK3_VALUE,
			    atth.PK4_VALUE,
			    atth.PK5_VALUE,
			    atth.AUTOMATICALLY_ADDED_FLAG,
			    atth.REQUEST_ID,
			    atth.PROGRAM_APPLICATION_ID,
			    atth.PROGRAM_ID,
			    atth.PROGRAM_UPDATE_DATE,
			    atth.ATTRIBUTE_CATEGORY,
			    atth.ATTRIBUTE1,
			    atth.ATTRIBUTE2,
			    atth.ATTRIBUTE3,
			    atth.ATTRIBUTE4,
			    atth.ATTRIBUTE5,
			    atth.ATTRIBUTE6,
			    atth.ATTRIBUTE7,
			    atth.ATTRIBUTE8,
			    atth.ATTRIBUTE9,
			    atth.ATTRIBUTE10,
			    atth.ATTRIBUTE11,
			    atth.ATTRIBUTE12,
			    atth.ATTRIBUTE13,
			    atth.ATTRIBUTE14,
			    atth.ATTRIBUTE15,

			    docs.DATATYPE_ID,
			    docs.CATEGORY_ID,
			    docs.SECURITY_TYPE,
			    docs.SECURITY_ID,
			    docs.PUBLISH_FLAG,
			    docs.IMAGE_TYPE,
			    docs.STORAGE_TYPE,
			    docs.USAGE_TYPE,
			    docs.START_DATE_ACTIVE,
			    docs.END_DATE_ACTIVE,

			    tl.LANGUAGE,
			    tl.DESCRIPTION,
			    docs.FILE_NAME,
			    docs.MEDIA_ID,
			    tl.DOC_ATTRIBUTE_CATEGORY,
			    tl.DOC_ATTRIBUTE1,
			    tl.DOC_ATTRIBUTE2,
			    tl.DOC_ATTRIBUTE3,
			    tl.DOC_ATTRIBUTE4,
			    tl.DOC_ATTRIBUTE5,
			    tl.DOC_ATTRIBUTE6,
			    tl.DOC_ATTRIBUTE7,
			    tl.DOC_ATTRIBUTE8,
			    tl.DOC_ATTRIBUTE9,
			    tl.DOC_ATTRIBUTE10,
			    tl.DOC_ATTRIBUTE11,
			    tl.DOC_ATTRIBUTE12,
			    tl.DOC_ATTRIBUTE13,
			    tl.DOC_ATTRIBUTE14,
			    tl.DOC_ATTRIBUTE15,
          docs.URL,
			    tl.TITLE

			from fnd_documents docs,
			     FND_ATTACHED_DOCUMENTS atth,
			     fnd_documents_tl tl

			where entity_name = ''FUN_TRX_BATCHES''
			      and tl.LANGUAGE=''' || icx_language || '''
			      and pk1_value=''' || l_partial_batch.BATCH_ID || '''
			      and docs.document_id = atth.document_id
			      and tl.document_id = atth.document_id';


			OPEN c_batch_attm FOR l_sqlstmt_batch;
			LOOP
			  FETCH	c_batch_attm INTO l_batch_attchmt_rec_type;
			  EXIT WHEN c_batch_attm%NOTFOUND;

select FND_ATTACHED_DOCUMENTS_S.nextval into l_batch_ATTACHED_DOCUMENT_ID from dual;
l_batch_DOCUMENT_ID := NULL;

			  fnd_attached_documents_pkg.Insert_Row(
			         X_Rowid    => l_batch_attchmt_rec_type.ROWID,
				 X_attached_document_id   => l_batch_ATTACHED_DOCUMENT_ID,
				 X_document_id        => l_batch_DOCUMENT_ID,
				X_creation_date       => l_batch_attchmt_rec_type.creation_date,
                     X_created_by => l_batch_attchmt_rec_type.created_by,

         X_last_update_date   => sysdate,
				 X_last_updated_by    => FND_GLOBAL.USER_ID,
				 X_last_update_login   => FND_GLOBAL.USER_ID,
				 X_seq_num     => l_batch_attchmt_rec_type.SEQ_NUM,
				 X_entity_name => l_batch_attchmt_rec_type.ENTITY_NAME,
				 X_column1      => l_batch_attchmt_rec_type.COLUMN1,
				 X_pk1_value     => l_batch_id,
				 X_pk2_value   => l_batch_attchmt_rec_type.PK2_VALUE,
				 X_pk3_value   => l_batch_attchmt_rec_type.PK3_VALUE,
				 X_pk4_value   => l_batch_attchmt_rec_type.PK4_VALUE,
				 X_pk5_value   => l_batch_attchmt_rec_type.PK5_VALUE,
				 X_automatically_added_flag   => l_batch_attchmt_rec_type.AUTOMATICALLY_ADDED_FLAG,
				 X_request_id     => l_batch_attchmt_rec_type.REQUEST_ID,
				 X_program_application_id => l_batch_attchmt_rec_type.PROGRAM_APPLICATION_ID,
				 X_program_id  => l_batch_attchmt_rec_type.PROGRAM_ID,
				 X_program_update_date => l_batch_attchmt_rec_type.PROGRAM_UPDATE_DATE,
				 X_Attribute_Category => l_batch_attchmt_rec_type.ATTRIBUTE_CATEGORY,
				 X_Attribute1 => l_batch_attchmt_rec_type.ATTRIBUTE1,
				 X_Attribute2 => l_batch_attchmt_rec_type.ATTRIBUTE2,
				 X_Attribute3 => l_batch_attchmt_rec_type.ATTRIBUTE3,
				 X_Attribute4 => l_batch_attchmt_rec_type.ATTRIBUTE4,
				 X_Attribute5 => l_batch_attchmt_rec_type.ATTRIBUTE5,
				 X_Attribute6 => l_batch_attchmt_rec_type.ATTRIBUTE6,
				 X_Attribute7 => l_batch_attchmt_rec_type.ATTRIBUTE7,
				 X_Attribute8 => l_batch_attchmt_rec_type.ATTRIBUTE8,
				 X_Attribute9 => l_batch_attchmt_rec_type.ATTRIBUTE9,
				 X_Attribute10 => l_batch_attchmt_rec_type.ATTRIBUTE10,
				 X_Attribute11 => l_batch_attchmt_rec_type.ATTRIBUTE11,
				 X_Attribute12 => l_batch_attchmt_rec_type.ATTRIBUTE12,
				 X_Attribute13 => l_batch_attchmt_rec_type.ATTRIBUTE13,
				 X_Attribute14 => l_batch_attchmt_rec_type.ATTRIBUTE14,
				 X_Attribute15 => l_batch_attchmt_rec_type.ATTRIBUTE15,


			         /*  columns necessary for creating a document on the fly */
				 X_datatype_id                  => l_batch_attchmt_rec_type.DATATYPE_ID,
				 X_category_id                  => l_batch_attchmt_rec_type.CATEGORY_ID,
				 X_security_type                => l_batch_attchmt_rec_type.SECURITY_TYPE,
				 X_security_id                => l_batch_attchmt_rec_type.SECURITY_ID,
				 X_publish_flag                 => l_batch_attchmt_rec_type.PUBLISH_FLAG,
				 X_image_type                   => l_batch_attchmt_rec_type.IMAGE_TYPE,
				 X_storage_type                => l_batch_attchmt_rec_type.STORAGE_TYPE,
				 X_usage_type                => l_batch_attchmt_rec_type.USAGE_TYPE,
				 X_language                     => l_batch_attchmt_rec_type.l_LANGUAGE,
				 X_description                  => l_batch_attchmt_rec_type.DESCRIPTION,
				 X_file_name                    => l_batch_attchmt_rec_type.FILE_NAME,
				 X_media_id                     => l_batch_attchmt_rec_type.MEDIA_ID,
				 X_doc_Attribute_Category       => l_batch_attchmt_rec_type.DOC_ATTRIBUTE_CATEGORY,
				 X_doc_Attribute1               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE1,
				 X_doc_Attribute2               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE2,
				 X_doc_Attribute3               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE3,
				 X_doc_Attribute4               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE4,
				 X_doc_Attribute5              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE5,
				 X_doc_Attribute6               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE6,
				 X_doc_Attribute7               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE7,
				 X_doc_Attribute8               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE8,
				 X_doc_Attribute9               => l_batch_attchmt_rec_type.DOC_ATTRIBUTE9,
				 X_doc_Attribute10              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE10,
				 X_doc_Attribute11              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE11,
				 X_doc_Attribute12              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE12,
				 X_doc_Attribute13              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE13,
				 X_doc_Attribute14              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE14,
				 X_doc_Attribute15              => l_batch_attchmt_rec_type.DOC_ATTRIBUTE15,
				X_create_doc => 'N',
         X_url                          => l_batch_attchmt_rec_type.URL,
				 X_title			=> l_batch_attchmt_rec_type.TITLE
				);
    END LOOP;
-- Bug  9756187 End

    		--Update Total of the newly created batch
    		SELECT SUM(INIT_AMOUNT_DR),
		SUM (INIT_AMOUNT_CR)
		INTO l_running_total_dr, l_running_total_cr
		FROM FUN_TRX_HEADERS
                WHERE BATCH_ID = l_batch_id;

                UPDATE FUN_TRX_BATCHES
    		SET RUNNING_TOTAL_DR = l_running_total_dr,
    		RUNNING_TOTAL_CR = l_running_total_cr
    		WHERE BATCH_ID = l_batch_id;

    		-- Update status of old transactions
		UPDATE FUN_TRX_HEADERS
		SET STATUS = 'REJECTED',
		REJECT_REASON = 'Swept to New Batch ' || l_batch_number,
		LAST_UPDATED_BY = fnd_global.user_id,
		LAST_UPDATE_DATE = sysdate,
        	LAST_UPDATE_LOGIN = fnd_global.login_id
		WHERE BATCH_ID = l_partial_batch.BATCH_ID
		AND STATUS IN ('SENT','ERROR','RECEIVED');

		-- Update status of old batch to complete
		UPDATE FUN_TRX_BATCHES
		SET STATUS = DECODE ((SELECT 1
				          FROM DUAL
				          WHERE EXISTS (SELECT 'X' FROM FUN_TRX_HEADERS
				          WHERE BATCH_ID = l_partial_batch.BATCH_ID
				          AND STATUS NOT IN ('COMPLETE', 'REJECTED'))), 1, 'SENT', 'COMPLETE'),
        	LAST_UPDATED_BY = fnd_global.user_id,
		LAST_UPDATE_DATE = sysdate,
        	LAST_UPDATE_LOGIN = fnd_global.login_id
		WHERE BATCH_ID = l_partial_batch.BATCH_ID;

	END LOOP;

END sweep_partial_batches;

/***********************************************
* Procedure Sweep_Transactions :
*           This API sweeps transactions from the given period to specified next   *
*    open period.                                                                  *
*                                                                                  *
***************************************************/
  PROCEDURE sweep_transactions
  (
        p_errbuff                       OUT NOCOPY VARCHAR2,
        p_retcode                       OUT NOCOPY NUMBER,
        p_api_version                   IN NUMBER,
        p_period_name                   IN VARCHAR2,
        p_trx_type_id                   IN NUMBER,
        p_sweep_GL_date                 IN DATE,
        p_debug                         IN VARCHAR2,
        p_close                         IN VARCHAR2
  ) IS
        cursor c_chk_open1(l_trx_type_id in Number)
         is
                Select 1 from dual where exists
                (Select 'X'  from
        fun_period_statuses fps,fun_system_options fso where p_sweep_GL_date
         >= fps.start_date and p_sweep_GL_date <= fps.end_date and
         status = 'O' and trx_type_id = l_trx_type_id
	AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        cursor c_chk_prd_open1(l_prd_name in Varchar2,l_trx_type_id in
        Number)    is
                Select 1 from dual where exists
                (Select 'X' from
        fun_period_statuses fps,fun_system_options fso where period_name = l_prd_name and
         trx_type_id = l_trx_type_id and status IN ('O','S')
	AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        cursor c_chk_open2(l_prd_name in Varchar2)  is
                Select 1 from dual where exists
                (Select 'X'
        from
        fun_period_statuses
        fps1, fun_period_statuses fps2,fun_system_options fso where p_sweep_GL_date
        >= fps1.start_date and p_sweep_GL_date <= fps1.end_date and
        fps1.status = 'O' and fps2.period_name = l_prd_name and fps2.status = 'S'
        and fps1.trx_type_id = fps2.trx_type_id
	AND fps1.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps1.inteco_period_type=nvl(fso.inteco_period_type,'~~')
	AND fps2.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps2.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        cursor c_chk_prd_open2(l_prd_name in Varchar2)    is
                Select 1 from dual where exists
                (Select 'X'
        from
        fun_period_statuses fps,fun_system_options fso where period_name = l_prd_name and status = 'O'
	AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'));
        l_count                 number;
        l_api_name              constant varchar2(30) :=  'SWEEPING_TRANSACTIONS';
        l_api_version           CONSTANT NUMBER := 1.0;
  BEGIN
        Print(' +++ Start of Sweeping Transactions +++');
        G_debug := nvl(p_debug,'Y');
        -- Standard Call to check for API compatibility
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                              p_api_version,
                                              l_api_name,
                                      G_PKG_NAME)
        THEN
                Print('Non compatible API call');
                p_errbuff := 'Non Compatible API';
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        /* Validate: Whether Required Fields Passed */
        IF ( P_api_version IS NULL OR
                p_sweep_GL_Date IS NULL OR
                 p_period_name IS NULL) THEN
                        p_errbuff  := 'Required Fields not Passed';
                Print('REQUIRED FIELDS NOT PASSED');
                Raise FND_API.G_EXC_ERROR;
        END IF;
        /*
        Validate the validity of passing parameters>
        */
        if (p_trx_type_id is not null) then
        /* Validate whether period passed is open */
        Print('Validation: Period to be sweeped should be Open Period');
                open c_chk_prd_open1(p_period_name,p_trx_type_id);
                fetch c_chk_prd_open1 into l_count;
                if (c_chk_prd_open1%notfound) then
                        p_errbuff  := 'Period name not in open period for the trx';
                        Print('Period name not in open period for the trx');
				Update fun_period_statuses set status = 'O' where
                		trx_type_id = p_trx_type_id and period_name = p_period_name;
                        Raise FND_API.G_EXC_ERROR;
                End If;
                close c_chk_prd_open1;
                Print('Updating Period Status to Sweep In Progress');
                /* Update period to Sweep In Progress */
                Update fun_period_statuses set status = 'S' where
                trx_type_id = p_trx_type_id and period_name = p_period_name
		AND (inteco_calendar,inteco_period_type) IN
		(SELECT nvl(inteco_calendar,'~~'),nvl(inteco_period_type,'~~') FROM fun_system_options);
                Print('Validation: GL_DATE Passed should be Open Period');
                /* Whether GL_DATE passed is in Open Period */
                open c_chk_open1(p_trx_type_id);
                fetch c_chk_open1 into l_count;
                if (c_chk_open1%notfound) then
                        p_errbuff  := 'GL DATE Passed is not in Open Period';
                        Print('GL_DATE Passed is not in Open Period');
				Update fun_period_statuses set status = 'O' where
                		trx_type_id = p_trx_type_id and period_name = p_period_name;
                        Raise FND_API.G_EXC_ERROR;
                End If;
                close c_chk_open1;
                Print('Sweeping the transactions');
                /* Update the Periods */
                Update fun_trx_batches set gl_date =
                p_sweep_GL_date Where gl_date >= (select start_date from
                fun_period_statuses fps,fun_system_options fso where fps.period_name = p_period_name and
                fps.trx_type_id = p_trx_type_id
		AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~')) and gl_Date <=
                (select end_date from fun_period_statuses fps,fun_system_options fso where fps.period_name
                = p_period_name and fps.trx_type_id = p_trx_type_id
		AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'))
                And trx_type_id = p_trx_type_id
                    And batch_id not in (SELECT h2.batch_id FROM fun_trx_headers h2 WHERE h2.status IN ('APPROVED', 'COMPLETE', 'XFER_RECI_GL',
	  'XFER_AR', 'XFER_INI_GL','XFER_AP','REJECTED')  AND   h2.batch_id = batch_id)
	   and status NOT IN ('COMPLETE', 'NEW');                                                      --  Bug No : 6880343

		-- 6892783: Added to Sweep Partially Complete Batches
		sweep_partial_batches(p_errbuff, p_period_name, p_trx_type_id, p_sweep_GL_date);

                /* Update the Status of Period as Closed */
                if (nvl(p_close,'Y') = 'Y') then
                        Update fun_period_statuses set status = 'C' where
                        trx_type_id = p_trx_type_id and period_name = p_period_name
                        AND (inteco_calendar,inteco_period_type) IN (SELECT nvl(inteco_calendar,'~~'),nvl(inteco_period_type,'~~') from fun_system_options);
                        Print('Closing for Period ');
                End If;
        Else
                /* Validate whether period passed is open */
                open c_chk_prd_open2(p_period_name);
                fetch c_chk_prd_open2 into l_count;
                if (c_chk_prd_open2%notfound) then
                        p_errbuff  := 'Period name not in open period for the trx';
                        Print('Period name not in open period for the trx');
                        Raise FND_API.G_EXC_ERROR;
                End If;
                close c_chk_prd_open2;
                /* Update period to Sweep In Progress */
                Update fun_period_statuses set status = 'S' where
                period_name = p_period_name and status = ('O');
                /* Whether GL_DATE passed is in Open Period */
                open c_chk_open2(p_period_name);
                fetch c_chk_open2 into l_count;
                if (c_chk_open2%notfound) then
                        p_errbuff  := 'GL DATE Passed is not in Open Period';
                        Print('GL_DATE Passed is not in Open Period');
                        Raise FND_API.G_EXC_ERROR;
                End If;
                close c_chk_open2;
                /* Sweep the transactions */
                Update fun_trx_batches set gl_date = p_sweep_GL_date
                Where gl_date >= (select distinct start_date from
                fun_period_statuses fps,fun_system_options fso where fps.period_name = p_period_name and
		fps.trx_type_id = p_trx_type_id
		AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'))
                and gl_Date <=  (select distinct end_date from fun_period_statuses fps,fun_system_options fso
                where fps.period_name = p_period_name and
		fps.trx_type_id = p_trx_type_id
		AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'))
				AND trx_type_id IN (select trx_type_id from fun_period_statuses fps,fun_system_options fso
                where fps.period_name = p_period_name and
		fps.trx_type_id = p_trx_type_id
		AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~'))
                And batch_id not in (SELECT h2.batch_id FROM fun_trx_headers h2 WHERE h2.status IN ('APPROVED', 'COMPLETE', 'XFER_RECI_GL',
	  'XFER_AR', 'XFER_INI_GL','XFER_AP','REJECTED')  AND   h2.batch_id = batch_id)
	   and status NOT IN ('COMPLETE', 'NEW');                                                                --  Bug No : 6880343

		-- 6892783: Added to Sweep Partially Complete Batches
		sweep_partial_batches(p_errbuff, p_period_name, p_trx_type_id, p_sweep_GL_date);

                /* Close the Period */
                if (nvl(p_close,'Y') = 'Y') then
                        Update fun_period_statuses set status = 'C' where period_name =
                                p_period_name and status in ('S')
				AND (inteco_calendar,inteco_period_type) IN (SELECT nvl(inteco_calendar,'~~'),nvl(inteco_period_type,'~~') FROM fun_system_options);
                        Print('Closing for Period for all trx types');
                End If;
        End If; /* if p_trx_type_id */
        p_errbuff  := null;
        p_retcode := 0;
        if (c_chk_open1%isopen) then
                close c_chk_open1;
        end if;
        if (c_chk_open2%isopen) then
                close c_chk_open2;
        end if;
        if (c_chk_prd_open1%isopen) then
                close c_chk_prd_open1;
        end if;
        if (c_chk_prd_open2%isopen) then
                close c_chk_prd_open2;
        end if;
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
               p_retcode := 2;
	/* As we are updating the status to 'S' before calling
	   this routine when trx_type_id is not null, hence we have
           to set status to 'O' if error happens, hence we cannot
	   rollback */
        if (p_trx_type_id is null) THEN
               rollback;
	end if;
        if (c_chk_open1%isopen) then
                close c_chk_open1;
        end if;
        if (c_chk_open2%isopen) then
                close c_chk_open2;
        end if;
        if (c_chk_prd_open1%isopen) then
                close c_chk_prd_open1;
        end if;
        if (c_chk_prd_open2%isopen) then
                close c_chk_prd_open2;
        end if;
        WHEN OTHERS THEN
        p_errbuff  := SQLERRM;
        Print(SQLERRM);
        p_retcode := 2;
        if (c_chk_open1%isopen) then
                close c_chk_open1;
        end if;
        if (c_chk_open2%isopen) then
                close c_chk_open2;
        end if;
        if (c_chk_prd_open1%isopen) then
                close c_chk_prd_open1;
        end if;
        if (c_chk_prd_open2%isopen) then
                close c_chk_prd_open2;
        end if;
  END sweep_transactions;
PROCEDURE insert_details_for_years (p_per_year number , p_per_type varchar2 , p_per_set_name varchar2,p_trx_type_id number)
AS
BEGIN
INSERT INTO fun_period_statuses
(PERIOD_NAME
 , PERIOD_YEAR
 , START_DATE
 , END_DATE
 ,YEAR_START_DATE
 ,QUARTER_START_DATE
 ,STATUS
 ,TRX_TYPE_ID
 ,PERIOD_NUM
 ,CREATED_BY
 ,LAST_UPDATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATE_LOGIN
 ,CREATION_DATE
 ,INTECO_CALENDAR
 ,INTECO_PERIOD_TYPE
)  SELECT  period_name ,period_year, START_DATE
 , END_DATE
 ,YEAR_START_DATE
 ,QUARTER_START_DATE
 ,'N'
 ,p_trx_type_id
 ,PERIOD_NUM
 ,FND_GLOBAL.LOGIN_ID
 ,FND_GLOBAL.LOGIN_ID
 ,SYSDATE
 ,FND_GLOBAL.LOGIN_ID
 ,sysdate
 ,inteco_calendar
 ,inteco_period_type
 from gl_periods,fun_system_options
where period_set_name = p_per_set_name  and period_type = p_per_type and
period_year >p_per_year;
END;
PROCEDURE insert_details_for_periods (p_per_year number , p_per_type varchar2 , p_per_set_name varchar2 , p_period_num number,p_trx_type_id number )
AS
BEGIN
INSERT INTO fun_period_statuses
(PERIOD_NAME
 , PERIOD_YEAR
 , START_DATE
 , END_DATE
 ,YEAR_START_DATE
 ,QUARTER_START_DATE
 ,STATUS
 ,TRX_TYPE_ID
 ,PERIOD_NUM
 ,CREATED_BY
 ,LAST_UPDATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATE_LOGIN
 ,CREATION_DATE
 ,INTECO_CALENDAR
 ,INTECO_PERIOD_TYPE
)  SELECT  period_name ,period_year, START_DATE
 , END_DATE
 ,YEAR_START_DATE
 ,QUARTER_START_DATE
 ,'N'
 ,p_trx_type_id
 ,PERIOD_NUM
 ,FND_GLOBAL.LOGIN_ID
 ,FND_GLOBAL.LOGIN_ID
 ,SYSDATE
 ,FND_GLOBAL.LOGIN_ID
 ,sysdate
 ,INTECO_CALENDAR
 ,INTECO_PERIOD_TYPE
 from gl_periods,
 fun_system_options
where period_set_name = p_per_set_name  and period_type = p_per_type and
period_year =p_per_year and period_num > p_period_num ;
END;
PROCEDURE sync_calendars IS
CURSOR c_min_gl_per_yr IS
select min(period_year) from gl_periods gl, fun_system_options fun
where
gl.period_set_name = fun.inteco_calendar
and gl.period_type = fun.inteco_period_type     ;
CURSOR c_max_gl_per_yr IS
select max(period_year) from gl_periods gl, fun_system_options fun
where
gl.period_set_name = fun.inteco_calendar
and gl.period_type = fun.inteco_period_type     ;
CURSOR c_max_gl_per_num(c_per_year number)IS
select max(period_num) from gl_periods gl , fun_system_options fun
where
gl.period_set_name = fun.inteco_calendar
and gl.period_type = fun.inteco_period_type
and gl.period_year = c_per_year;
CURSOR c_max_fun_per_yr IS
select max(period_year) period_year,trx_type_id from fun_period_statuses fps, fun_system_options fso
WHERE fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~')
group by trx_type_id ;
CURSOR c_max_fun_per_num(c_per_yr number,c_trx_type number ) IS
select max(period_num) from fun_period_statuses fps,fun_system_options fso
where period_year = c_per_yr
and trx_type_id = c_trx_type
AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~');
CURSOR c_inexist_fun_trx(c_per_year number,c_per_name varchar2 ) IS
select trx_type_id from fun_trx_types_vl v
where  not exists
    ( select fps.trx_type_id  from fun_period_statuses fps,fun_system_options fso
      WHERE fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~') and fps.period_year = c_per_year
				and fps.period_name = c_per_name
     and fps.trx_type_id =  v.trx_type_id);

l_min_gl_year number;
l_gl_year number;
l_gl_num number;
l_sys_opt_cal_name varchar2(50);
l_sys_opt_per_type varchar2(50);
l_fun_num number;
--Bug: 7006981
l_max_fun_year number(15,0);
l_fun_trx_type_id number(15,0);
l_PERIOD_NUM number(15,0);
l_period_name VARCHAR2(15);
-- End Bug: 7006981
PRAGMA autonomous_transaction;
BEGIN
/********* Open cursor for gl  details *****************/
OPEN c_max_gl_per_yr;
FETCH c_max_gl_per_yr into l_gl_year ;
CLOSE c_max_gl_per_yr;
OPEN c_max_gl_per_num(l_gl_year);
FETCH c_max_gl_per_num into l_gl_num ;
CLOSE c_max_gl_per_num;
SELECT inteco_calendar,inteco_period_type into l_sys_opt_cal_name , l_sys_opt_per_type from fun_system_options;
/************* for inexistent trx types ********************/
OPEN c_min_gl_per_yr;
FETCH c_min_gl_per_yr into l_min_gl_year ;
CLOSE c_min_gl_per_yr;
--Bug 7006981

OPEN c_max_fun_per_yr;
  FETCH c_max_fun_per_yr INTO l_max_fun_year,l_fun_trx_type_id;
  IF c_max_fun_per_yr%notfound THEN
	for l_inexist_fun_trx in c_inexist_fun_trx(0, 'No FUN Periods')
	loop
	/***** Call procedure to insert for the year passed  insert_details_for_years ****/
            --Bug: 6512412. Passing l_min_gl_year-1 instead of l_min_gl_year.
            insert_details_for_years (p_per_year => (l_min_gl_year-1),
                                      p_per_type => l_sys_opt_per_type,
                                      p_per_set_name =>l_sys_opt_cal_name ,p_trx_type_id => l_inexist_fun_trx.trx_type_id);
	end loop;
  ELSE
  	select PERIOD_NUM, period_name
	into l_PERIOD_NUM, l_period_name
	from
	(select min(fps.PERIOD_NUM) PERIOD_NUM, fps.period_name from fun_period_statuses fps, fun_system_options fso
	where fps.period_year = l_max_fun_year
	AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
					AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~')
	group by fps.period_name
	order by 1 asc )
	where rownum = 1;
	--call modified with l_max_fun_year, l_PERIOD_NUM;
	for l_inexist_fun_trx in c_inexist_fun_trx( l_max_fun_year, l_period_name)
	loop
	/***** Call procedure to insert for the year passed  insert_details_for_years ****/
            --Bug: 6512412. Passing l_min_gl_year-1 instead of l_min_gl_year.
            insert_details_for_years (p_per_year => (l_min_gl_year-1),
                                      p_per_type => l_sys_opt_per_type,
                                      p_per_set_name =>l_sys_opt_cal_name ,p_trx_type_id => l_inexist_fun_trx.trx_type_id);
	end loop;
  END IF;
 CLOSE c_max_fun_per_yr;
  --End 7006981

FOR l_max_fun_per_yr in c_max_fun_per_yr
loop
   /********* Case 1: All Periods defined correct in this trx **********************/
   if (l_max_fun_per_yr.period_year = l_gl_year ) then
        OPEN c_max_fun_per_num(l_max_fun_per_yr.period_year,l_max_fun_per_yr.trx_type_id);
        FETCH  c_max_fun_per_num into l_fun_num;
        if (l_fun_num < l_gl_num) then
            /***** Call procedure to insert for the year passed insert_details_for_years****/
            insert_details_for_periods (p_per_year => (l_gl_year), -- bug 6761607.
                                            p_per_type => l_sys_opt_per_type,
                                            p_per_set_name =>l_sys_opt_cal_name ,
                                            p_period_num => l_fun_num, p_trx_type_id => l_max_fun_per_yr.trx_type_id);
        end if ;
        CLOSE c_max_fun_per_num;
    /********* Case 2: All Periods not defined from particular year onwards in this trx **********************/
    elsif (l_max_fun_per_yr.period_year < l_gl_year )    then
        OPEN c_max_fun_per_num(l_max_fun_per_yr.period_year,l_max_fun_per_yr.trx_type_id) ;
        FETCH  c_max_fun_per_num into l_fun_num;
	-- bug 6761607.
          --  if (l_fun_num < l_gl_num ) then
                /***** Call procedure to insert for the year passed  insert_details_for_periods ****/
                insert_details_for_periods (p_per_year => l_max_fun_per_yr.period_year,
                                            p_per_type => l_sys_opt_per_type,
                                            p_per_set_name =>l_sys_opt_cal_name ,
                                            p_period_num => l_fun_num, p_trx_type_id => l_max_fun_per_yr.trx_type_id);
                /***** Call procedure to insert for the year passed  insert_details_for_years ****/
		-- bug 6761607.
                /*insert_details_for_years (p_per_year => l_max_fun_per_yr.period_year,
                                          p_per_type => l_sys_opt_per_type,
                                          p_per_set_name =>l_sys_opt_cal_name ,p_trx_type_id => l_max_fun_per_yr.trx_type_id); */
           -- end if ;  bug 6761607.
            /***** Call procedure to insert for the year passed  insert_details_for_years ****/
            insert_details_for_years (p_per_year => l_max_fun_per_yr.period_year,
                                      p_per_type => l_sys_opt_per_type,
                                      p_per_set_name =>l_sys_opt_cal_name ,p_trx_type_id => l_max_fun_per_yr.trx_type_id);
        CLOSE c_max_fun_per_num;
  end if;
end loop;
COMMIT;
end;
/***********************************************
* Function get_fun_prd_status :
*          This API accepts date and trx type and returns status in Intercompany   *
*                                                                                  *
***************************************************/
FUNCTION  get_fun_prd_status(p_date Date, p_trx_type_id number)
RETURN VARCHAR2 IS
CURSOR c_calendar_defined IS
SELECT fso.inteco_calendar,fso.inteco_period_type
FROM fun_system_options fso;
CURSOR c_select_status IS
       select fps.status
       from fun_period_statuses fps,fun_system_options fso,
            fun_trx_types_vl ftt
       where  trunc(p_date) between fps.start_date and fps.end_date
         and  fps.trx_type_id = ftt.trx_type_id
         and  ftt.trx_type_id = p_trx_type_id
	 AND fps.inteco_calendar=nvl(fso.inteco_calendar,'~~')
				AND fps.inteco_period_type=nvl(fso.inteco_period_type,'~~');
l_status VARCHAR2(1);
l_inteco_calendar varchar2(50);
l_period_type varchar2(50);
BEGIN
  OPEN c_calendar_defined;
  FETCH c_calendar_defined INTO l_inteco_calendar,l_period_type;
  IF c_calendar_defined%notfound THEN
	l_status:='O';
  ELSIF l_inteco_calendar IS NULL OR l_period_type IS NULL THEN
	l_status:='O';
  ELSE
  	OPEN c_select_status;
  	FETCH c_select_status into l_status;
  	if c_select_status%notfound then
        	l_status :='C';
  	end if;
  	CLOSE c_select_status;
  END IF;
  CLOSE c_calendar_defined;
  RETURN l_status;
END;
END FUN_PERIOD_STATUS_PKG;  -- Package Body


/
