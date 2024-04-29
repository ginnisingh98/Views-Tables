--------------------------------------------------------
--  DDL for Package Body LNS_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_CUSTOM_PUB" AS
/* $Header: LNS_CUST_PUBP_B.pls 120.2.12010000.18 2010/05/20 14:07:21 scherkas ship $ */
 G_DEBUG_COUNT               CONSTANT NUMBER := 0;
 G_DEBUG                     CONSTANT BOOLEAN := FALSE;

 G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'LNS_CUSTOM_PUB';


---------------------------------------------------------------------------
 -- internal package routines
---------------------------------------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

    if FND_GLOBAL.Conc_Request_Id is not null then
        fnd_file.put_line(FND_FILE.LOG, message);
    end if;

end;

/* this funciton will ensure the rows in the custom tbl are ordered by payment number
|| will NOT validate that payment numbers are unique. this should be done prior to sorting
 */
procedure sortRows(p_custom_tbl in out nocopy LNS_CUSTOM_PUB.custom_tbl)

is
    l_return_tbl LNS_CUSTOM_PUB.custom_tbl;
    j            number;
    l_tmp_row    lns_custom_pub.custom_sched_type;
    l_number     number;
    l_min        number;
    l_tmp        number;

begin
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - sorting the rows');
    for i in 1..p_custom_tbl.count loop
        l_min := p_custom_tbl(i).payment_number;

        for j in i + 1..p_custom_tbl.count loop

            if p_custom_tbl(j).payment_number < l_min then
                l_min := p_custom_tbl(j).payment_number;
                l_tmp_row := p_custom_tbl(i);
                p_custom_tbl(i) := p_custom_tbl(j);
                p_custom_tbl(j) := l_tmp_row;
            end if;
        end loop;
    end loop;
end ;

/*=========================================================================
|| PUBLIC PROCEDURE resetCustomSchedule
||
|| DESCRIPTION
||
|| Overview: resets a customized payment schedule for a loan
||
|| Parameter: loan_id => loan id to reset
||
|| Return value: standard API outputs
||
|| Source Tables:  NA
||
|| Target Tables:  LNS_CUSTOM_PAYMENT_SCHEDULE, LNS_LOAN_HEADER
||
|| Return value:
||
|| KNOWN ISSUES
||       you cannot reset a customized loan once billing begins
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 11:35AM     raverma           Created
||
 *=======================================================================*/
procedure resetCustomSchedule(p_loan_id        IN number
                             ,p_init_msg_list  IN VARCHAR2
                             ,p_commit         IN VARCHAR2
                             ,p_update_header  IN boolean
                             ,x_return_status  OUT NOCOPY VARCHAR2
                             ,x_msg_count      OUT NOCOPY NUMBER
                             ,x_msg_data       OUT NOCOPY VARCHAR2)

is
   l_api_name                varchar2(25);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_return_Status           VARCHAR2(1);
   l_last_installment_billed NUMBER;
   l_loan_details            LNS_FINANCIALS.LOAN_DETAILS_REC;
   l_customized              varchar2(1);
   l_loan_header_rec         LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
   l_object_version          number;
   l_skip_update             boolean;

   cursor c_customized (p_loan_id number) is
   SELECT nvl(h.custom_payments_flag, 'N')
     FROM lns_loan_headers_all h
    WHERE loan_id = p_loan_id;

begin

    -- Standard Start of API savepoint
    SAVEPOINT resetCustomSchedule;
    l_api_name                := 'resetCustomSchedule';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- --------------------------------------------------------------------
    -- Api body
    -- --------------------------------------------------------------------
    -- validate loan_id
    lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                   ,p_init_msg_list  =>  'T'
                                   ,x_msg_count      =>  l_msg_count
                                   ,x_msg_data       =>  l_msg_data
                                   ,x_return_status  =>  l_return_status
                                   ,p_col_id         =>  p_loan_id
                                   ,p_col_name       =>  'LOAN_ID'
                                   ,p_table_name     =>  'LNS_LOAN_HEADERS_ALL');

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', p_loan_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- check to see if the loan is customized
    open c_customized(p_loan_id);
    fetch c_customized into l_customized;
    close c_customized;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - customized = ' || l_customized);

    if l_customized = 'N' then
        l_skip_update := true;
        /* dont raise this error as per karamach conversation   12-1-2004
         FND_MESSAGE.Set_Name('LNS', 'LNS_NOT_CUSTOMIZED');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
        */
    else
        -- loan is customized
        l_skip_update := false;

        -- check to see if the loan has ever been billed
        l_last_installment_billed := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment ' || l_last_installment_billed);

        if l_last_installment_billed > 0 then
             FND_MESSAGE.Set_Name('LNS', 'LNS_LOAN_ALREADY_BILLED');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
        end if;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - deleting custom rows');
        delete
          from lns_custom_paymnt_scheds
         where loan_id = p_loan_id;

    end if;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - resetting header');
    if p_update_header and not l_skip_update then
          select object_version_number into l_object_version
            from lns_loan_headers_all
           where loan_id = p_loan_id;
          l_loan_header_rec.loan_id := p_loan_id;
          l_loan_header_rec.custom_payments_flag := 'N';
          lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_FALSE
                                         ,p_loan_header_rec       => l_loan_header_rec
                                         ,p_object_version_number => l_object_version
                                         ,x_return_status         => l_return_status
                                         ,x_msg_count             => l_msg_count
                                         ,x_msg_data              => l_msg_data);

    else
        null;
    end if;
    -- --------------------------------------------------------------------
    -- End of API body
    -- --------------------------------------------------------------------

    -- Standard check for p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              ROLLBACK TO resetCustomSchedule;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              ROLLBACK TO resetCustomSchedule;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              ROLLBACK TO resetCustomSchedule;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end resetCustomSchedule;

/*=========================================================================
|| PUBLIC PROCEDURE createCustomSchedule
||
|| DESCRIPTION
||
|| Overview: creates a custom payment schedule for a loan
||
|| Parameter: loan_id => loan id to customize
||            p_custom_tbl => table of records about custom schedule
||
|| Return value: standard API outputs
||
|| Source Tables:  NA
||
|| Target Tables:  LNS_CUSTOM_PAYMENT_SCHEDULE
||
|| Return value:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 11:35AM     raverma           Created
||
 *=======================================================================*/
procedure createCustomSchedule(p_custom_tbl     IN CUSTOM_TBL
                              ,p_loan_id        IN number
                              ,p_init_msg_list  IN VARCHAR2
                              ,p_commit         IN VARCHAR2
                              ,x_return_status  OUT NOCOPY VARCHAR2
                              ,x_msg_count      OUT NOCOPY NUMBER
                              ,x_msg_data       OUT NOCOPY VARCHAR2
                              ,X_INVALID_INSTALLMENT_NUM OUT NOCOPY NUMBER)

is
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_installment           NUMBER;
    l_custom_rec            custom_sched_type;
    l_custom_sched_id       NUMBER;
    m                       number;

    l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_object_version        number;
    g_object_version        number;
    l_custom_tbl            LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_api_name              varchar2(25);
    l_loan_start_date       date;
    l_original_loan_amount  number;
    l_fee_amount            number;

    -- for fees
    l_fee_structures                 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fees_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                  LNS_FEE_ENGINE.FEE_BASIS_TBL;

    -- total fees on the schedule by installment
    cursor c_fees(p_loan_id number, p_installment number) is
    select nvl(sum(sched.fee_amount), 0)
      from lns_fee_schedules sched
          ,lns_fees struct
     where sched.loan_id = p_loan_id
       and sched.fee_id = struct.fee_id
       and fee_installment = p_installment
       and active_flag = 'Y';

    cursor c_loan_details(p_loan_id number) is
    select loan_start_date, funded_amount
      from lns_loan_headers
     where loan_id = p_loan_id;

begin
      l_api_name            := 'createCustomSchedule';
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id: ' || p_loan_id);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rows received: ' || p_custom_tbl.count);
      SAVEPOINT createCustomSchedule;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      --l_custom_tbl := p_custom_tbl;
      m            := 0;

      for j in 1..p_custom_tbl.count loop
          if p_custom_tbl(j).payment_number > 0 then
           m := m + 1;
           l_custom_tbl(m) := p_custom_tbl(j);
          end if;
      end loop;

      lns_custom_pub.validateCustomTable(p_cust_tbl       => l_custom_tbl
                                        ,p_loan_id        => p_loan_id
                                        ,p_create_flag    => true
                                        ,x_installment    => l_installment
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - validateCustom ' || l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          if l_installment is not null then
            X_INVALID_INSTALLMENT_NUM := l_installment;
            FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INSTALLMENT');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'INSTALLMENT');
            FND_MESSAGE.SET_TOKEN('VALUE', l_installment);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          end if;
           FND_MESSAGE.Set_Name('LNS', 'LNS_VALIDATE_CUSTOM_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      end if;

      open c_loan_details(p_loan_id);
      fetch c_loan_details into l_loan_start_date, l_original_loan_amount;
      close c_loan_details;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting fee structures');
      -- now we've passed validation initialize loan_begin_balance to calculate balances
      l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                               ,p_fee_category => 'EVENT'
                                                               ,p_fee_type     => 'EVENT_ORIGINATION'
                                                               ,p_installment  => null
                                                               ,p_phase        => 'TERM'
                                                               ,p_fee_id       => null);

      l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                         ,p_fee_category => 'RECUR'
                                                         ,p_fee_type     => null
                                                         ,p_installment  => null
                                                         ,p_phase        => 'TERM'
                                                         ,p_fee_id       => null);
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count is ' || l_fee_structures.count);
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': orig structures count is ' || l_orig_fee_structures.count);

      m := 0;
      -- 2-24-2005 raverma add 0 installment to amortization schedule
      if l_orig_fee_structures.count > 0 then

         open c_fees(p_loan_id, 0);
         fetch c_fees into l_fee_amount;
         close c_fees;

         if l_fee_amount > 0 then
             m := l_custom_tbl.count + 1;
             l_custom_rec.payment_number       := 0;
             l_custom_rec.due_date             := l_loan_start_date;
             l_custom_rec.principal_amount     := 0;
             l_custom_rec.interest_amount      := 0;
             l_custom_rec.fee_amount           := l_fee_amount;
             l_custom_rec.other_amount         := 0;
             l_custom_rec.installment_begin_balance        := l_original_loan_amount;
             l_custom_rec.installment_end_balance          := l_original_loan_amount;
             l_custom_rec.INTEREST_PAID_TODATE  := 0;
             l_custom_rec.PRINCIPAL_PAID_TODATE := 0;
             --l_custom_rec.fees_cumulative      := l_fee_amount;
             --l_custom_rec.other_cumulative     := 0;
             -- add the record to the amortization table
             l_custom_rec.CURRENT_TERM_PAYMENT := l_fee_amount;
             --l_custom_tbl(m)                   := l_custom_rec;
         end if;

         --l_orig_fees_tbl.delete;
         l_fee_amount := 0;

      end if;
      l_custom_tbl(1).installment_begin_balance := lns_financials.getRemainingBalance(p_loan_id);

      for k in 1..l_custom_tbl.count
      loop
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'custom_schedule_id: ' || l_custom_tbl(k).custom_schedule_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'principal_amount : ' || l_custom_tbl(k).principal_amount);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'interest_amount : ' || l_custom_tbl(k).interest_amount);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'due_date : ' || l_custom_tbl(k).due_date);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'object_version_number : ' || l_custom_tbl(k).object_version_number);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'installment_begin_balance : ' || l_custom_tbl(k).installment_begin_balance);

         l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
         l_fee_basis_tbl(1).fee_basis_amount := l_custom_tbl(k).installment_begin_balance;
         l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
         l_fee_basis_tbl(2).fee_basis_amount := l_original_loan_amount;

         if k = 1 then
             if l_orig_fee_structures.count > 0 then
              lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                          ,p_installment      => k
                                          ,p_fee_basis_tbl    => l_fee_basis_tbl
                                          ,p_fee_structures   => l_orig_fee_structures
                                          ,x_fees_tbl         => l_orig_fees_tbl
                                          ,x_return_status    => l_return_status
                                          ,x_msg_count        => l_msg_count
                                          ,x_msg_data         => l_msg_data);
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fee_structures.count);
             end if;
         end if;

         if l_fee_structures.count > 0 then
              lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                          ,p_installment      => k
                                          ,p_fee_basis_tbl    => l_fee_basis_tbl
                                          ,p_fee_structures   => l_fee_structures
                                          ,x_fees_tbl         => l_fees_tbl
                                          ,x_return_status    => l_return_status
                                          ,x_msg_count        => l_msg_count
                                          ,x_msg_data         => l_msg_data);
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated fees ' || l_fees_tbl.count);

         end if;

         for i in 1..l_orig_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_orig_fees_tbl(i).FEE_AMOUNT;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': orig calculated fees ' || l_fee_amount);
         end loop;

         for j in 1..l_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_fees_tbl(j).FEE_AMOUNT;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': recurring calculated fees ' || l_fee_amount);
         end loop;

        l_custom_rec.LOAN_ID             := p_loan_id;
        l_custom_rec.PAYMENT_NUMBER      := l_custom_tbl(k).payment_number;
        l_custom_rec.PRINCIPAL_AMOUNT    := l_custom_tbl(k).principal_amount;
        l_custom_rec.INTEREST_AMOUNT     := l_custom_tbl(k).interest_amount;
        --l_custom_rec.FEE_AMOUNT          := l_custom_tbl(k).fee_amount;
        l_custom_rec.FEE_AMOUNT          := l_fee_amount;
        l_custom_rec.OTHER_AMOUNT        := l_custom_tbl(k).other_amount;
        l_custom_rec.DUE_DATE            := l_custom_tbl(k).due_date;
        l_custom_rec.current_term_payment  := l_custom_rec.FEE_AMOUNT + l_custom_rec.INTEREST_AMOUNT + l_custom_rec.PRINCIPAL_AMOUNT;
        --l_custom_rec.OBJECT_VERSION_NUMBER := p_custom_tbl(k).object_version_number;
        l_custom_rec.installment_begin_balance := l_custom_tbl(k).installment_begin_balance;
        l_custom_rec.installment_end_balance  := l_custom_tbl(k).installment_begin_balance - l_custom_tbl(k).principal_amount;

        -- now calculate the balances
        if l_custom_rec.installment_end_balance > 0 and k <> l_custom_tbl.count then
          l_custom_tbl(k + 1).installment_begin_balance := l_custom_rec.installment_end_balance;
        end if;

        -- call api to update rows one-by-one for compliance reasons
        lns_custom_pub.createCustomSched(P_CUSTOM_REC      => l_custom_rec
                                        ,x_return_status   => l_return_status
                                        ,x_custom_sched_id => l_custom_sched_id
                                        ,x_msg_count       => l_msg_Count
                                        ,x_msg_data        => l_msg_Data);
       -- dbms_output.put_line('after create API ' || l_return_status);

      end loop;

      -- if we get this far now we update the header table flag for custom payments
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - attempting to update header set custom = Y');
      select object_version_number into l_object_version
        from lns_loan_headers_all
       where loan_id = p_loan_id;
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_object_version ' || l_object_version);

      l_loan_header_rec.loan_id              := p_loan_id;
      l_loan_header_rec.CUSTOM_PAYMENTS_FLAG := 'Y';

      lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_FALSE
                                     ,p_loan_header_rec       => l_loan_header_rec
                                     ,P_OBJECT_VERSION_NUMBER => l_object_version
                                     ,X_RETURN_STATUS         => l_return_status
                                     ,X_MSG_COUNT             => l_msg_count
                                     ,X_MSG_DATA              => l_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_msg_count ' || l_msg_count);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_msg_data ' || l_msg_data);

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - header update set custom = Y');

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - header update ERROR');
            FND_MESSAGE.Set_Name('LNS', 'LNS_HEADER_UPDATE_ERROR');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      end if;

      IF FND_API.to_Boolean(p_commit)
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             FND_MESSAGE.Set_Name('LNS', 'LNS_CREATE_CUSTOM_ERROR');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO createCustomSchedule;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             FND_MESSAGE.Set_Name('LNS', 'LNS_CREATE_CUSTOM_ERROR');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO createCustomSchedule;

        WHEN OTHERS THEN
             FND_MESSAGE.Set_Name('LNS', 'LNS_CREATE_CUSTOM_ERROR');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO createCustomSchedule;

end;


/*=========================================================================
|| PUBLIC PROCEDURE updateCustomSchedule
||
|| DESCRIPTION
||
|| Overview: updates a custom payment schedule for a loan
||
|| Parameter: loan_id => loan id to customize
||            p_custom_tbl => table of records about custom schedule
||
|| Return value: standard API outputs
||
|| Source Tables:  NA
||
|| Target Tables:  LNS_CUSTOM_PAYMENT_SCHEDULE
||
|| Return value:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 11:35AM     raverma           Created
||
 *=======================================================================*/
procedure updateCustomSchedule(p_custom_tbl     IN CUSTOM_TBL
                              ,p_loan_id        IN number
                              ,p_init_msg_list  IN VARCHAR2
                              ,p_commit         IN VARCHAR2
                              ,x_return_status  OUT NOCOPY VARCHAR2
                              ,x_msg_count      OUT NOCOPY NUMBER
                              ,x_msg_data       OUT NOCOPY VARCHAR2
                              ,X_INVALID_INSTALLMENT_NUM OUT NOCOPY NUMBER)

is
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_installment           NUMBER;
    l_custom_rec            custom_sched_type;
    l_total_amount          NUMBER;
    l_custom_tbl            LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_custom_tbl2           LNS_CUSTOM_PUB.CUSTOM_TBL;

    l_api_name              varchar2(25);


    /* destroy records already billed
     */
    cursor c_records_to_destroy (p_loan_id number) is
    select count(1)
      from lns_amortization_scheds
     where reamortization_amount is null
       and reversed_flag <> 'Y'
       and loan_id = p_loan_id
       and payment_number > 0
       and parent_amortization_id is null;

    l_records_to_destroy     number;
    l_num_records            number;
    l_records_to_copy        number;
    l_count                  number;

    -- we will need to get the PK since runAmortization API does not reutrn PKs
    cursor c_cust_sched_id (p_loan_id number, p_payment_number number) is
    select custom_schedule_id, object_version_number
      from lns_custom_paymnt_scheds
     where loan_id = p_loan_id
       and payment_number = p_payment_number;

begin
      l_api_name              := 'updateCustomSchedule';
      SAVEPOINT updateCustomSchedule;
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id: ' || p_loan_id);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rows received: ' || p_custom_tbl.count);
      l_custom_tbl2 := p_custom_tbl;

      open c_records_to_destroy(p_loan_id);
        fetch c_records_to_destroy into l_records_to_destroy;
      close c_records_to_destroy;
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - destroy to: ' || l_records_to_destroy);
      -- also destroy the 0th row
      l_count := 0;
      for k in 1..l_custom_tbl2.count loop

        if l_custom_tbl2(k).payment_number > l_records_to_destroy then
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' adding '|| l_custom_tbl2(k).payment_number);
            l_count := l_count + 1;
            l_custom_tbl(l_count) := l_custom_tbl2(k);
        end if;
      end loop;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after clean up records');
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - num records is '|| l_custom_tbl.count);

      lns_custom_pub.validateCustomTable(p_cust_tbl       => l_custom_tbl
                                        ,p_loan_id        => p_loan_id
                                        ,p_create_flag    => false
                                        ,x_installment    => l_installment
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            if l_installment is not null then
              X_INVALID_INSTALLMENT_NUM := l_installment;
              FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INSTALLMENT');
              FND_MESSAGE.SET_TOKEN('PARAMETER', 'INSTALLMENT');
              FND_MESSAGE.SET_TOKEN('VALUE', l_installment);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            end if;
             FND_MESSAGE.Set_Name('LNS', 'LNS_VALIDATE_CUSTOM_ERROR');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
        end if;

        -- now we've passed validation initialize loan_begin_balance to calculate balances
        l_custom_tbl2(1).installment_begin_balance := lns_financials.getRemainingBalance(p_loan_id);

        for k in 1..l_custom_tbl.count
        loop

          open c_cust_sched_id(p_loan_id, l_custom_tbl(k).payment_number);
          fetch c_cust_sched_id into
                 l_custom_tbl(k).custom_schedule_id
                ,l_custom_tbl(k).object_version_number;
          close c_cust_sched_id;

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'custom_schedule_id: ' || l_custom_tbl(k).custom_schedule_id);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'principal_amount : ' || l_custom_tbl(k).principal_amount);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'interest_amount : ' || l_custom_tbl(k).interest_amount);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'due_date : ' || l_custom_tbl(k).due_date);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'object_version_number : ' || l_custom_tbl(k).object_version_number);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'installment_begin_balance : ' || l_custom_tbl(k).installment_begin_balance);

          l_custom_rec.CUSTOM_SCHEDULE_ID  := l_custom_tbl(k).custom_schedule_id;
          l_custom_rec.LOAN_ID             := p_loan_id;
          --l_custom_rec.PAYMENT_NUMBER      := k;
          l_custom_rec.PRINCIPAL_AMOUNT    := l_custom_tbl(k).principal_amount;
          l_custom_rec.INTEREST_AMOUNT     := l_custom_tbl(k).interest_amount;
          l_custom_rec.FEE_AMOUNT          := l_custom_tbl(k).fee_amount;
          l_custom_rec.OTHER_AMOUNT        := l_custom_tbl(k).other_amount;
          l_custom_rec.DUE_DATE            := l_custom_tbl(k).due_date;
          l_custom_rec.current_term_payment      := l_custom_rec.Fee_AMOUNT + l_custom_rec.INTEREST_AMOUNT + l_custom_rec.PRINCIPAL_AMOUNT;
          l_custom_rec.OBJECT_VERSION_NUMBER     := l_custom_tbl(k).object_version_number;
          l_custom_rec.installment_begin_balance := l_custom_tbl(k).installment_begin_balance;
          l_custom_rec.installment_end_balance  := l_custom_tbl(k).installment_begin_balance - l_custom_tbl(k).principal_amount;

          -- now calculate the balances
          if l_custom_rec.installment_end_balance > 0 and k <> l_custom_tbl.count then
            l_custom_tbl(k+1).installment_begin_balance := l_custom_rec.installment_end_balance;
          end if;

          -- call api to update rows one-by-one for compliance reasons
          lns_custom_pub.updateCustomSched(P_CUSTOM_REC    => l_custom_rec
                                          ,x_return_status => l_return_status
                                          ,x_msg_count     => l_msg_Count
                                          ,x_msg_data      => l_msg_Data);

        end loop;

      IF FND_API.to_Boolean(p_commit)
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             --FND_MESSAGE.Set_Name('LNS', 'LNS_UPDATE_CUSTOM_ERROR');
             --FND_MSG_PUB.Add;
             --RAISE FND_API.G_EXC_ERROR;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateCustomSchedule;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             --FND_MESSAGE.Set_Name('LNS', 'LNS_UPDATE_CUSTOM_ERROR');
             --FND_MSG_PUB.Add;
             --RAISE FND_API.G_EXC_ERROR;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateCustomSchedule;

        WHEN OTHERS THEN
             --FND_MESSAGE.Set_Name('LNS', 'LNS_UPDATE_CUSTOM_ERROR');
             --FND_MSG_PUB.Add;
             --RAISE FND_API.G_EXC_ERROR;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateCustomSchedule;

end;


procedure validateCustomTable(p_cust_tbl         in CUSTOM_TBL
                             ,p_loan_id          in number
                             ,p_create_flag      in boolean
                             ,x_installment      OUT NOCOPY NUMBER
                             ,x_return_status    OUT NOCOPY VARCHAR2
                             ,x_msg_count        OUT NOCOPY NUMBER
                             ,x_msg_data         OUT NOCOPY VARCHAR2)
Is
  l_count         number;
  l_amount        number;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_return_Status VARCHAR2(1);
  l_date          DATE;
  l_api_name      varchar2(35);
  l_cust_tbl      custom_tbl;
  l_loan_details  LNS_FINANCIALS.LOAN_DETAILS_REC;

Begin
  l_api_name      := 'validateCustomTable';
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Begin');
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'in table count is ' || p_cust_tbl.count);
  -- check if number of incoming rows matches rows on loan_id custom_table
  -- only if this is an UPDATE
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'validate customtbl begin');
  l_cust_tbl     := p_cust_tbl;

  l_loan_details  := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                  ,p_based_on_terms => 'CURRENT'
                                                  ,p_phase          => 'TERM');
  l_count  := 0;
  l_amount := 0;
  -- destroy any rows prior to the last billed installment
  -- order the rows --
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'before sort');
  sortRows(p_custom_tbl => l_cust_tbl);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'after sort');

  -- checking updateCustomSchedule first
  if not p_create_flag then
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'in update validation');
     -- here i need to know only the number of rows that have not been billed
     Execute Immediate
     ' Select count(1)                ' ||
     '   From lns_amortization_scheds ' ||
     '  where loan_id = :p_loan_id    ' ||
     '    and reversed_flag <> ''Y''  ' ||
     '    and reamortization_amount is null ' ||
     '    and payment_number > 0      ' ||
     '    and parent_amortization_id is null '
     into l_count
     using p_loan_id;

     --open c_installments(p_loan_id);
     --fetch c_installments into l_installments;
     --close c_installments;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'original installments ' || l_loan_details.number_installments);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'billed installments (without 0) is ' || l_count);

    if l_loan_details.number_installments  - l_count <> l_cust_tbl.count then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_NUM_ROWS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'passed update validation');
  end if;

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'create / update validation');
  -- now checking each row in the createCustomSchedule
  for i in 1..l_cust_tbl.count
  loop
     /* the begin balance for the first row does not incorporate unpaid billed
      if i = 1 then
        -- check that first row in custom table is = remainingBalance
        -- CHECK THIS WITH KARTHIK
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'check balance');
        if l_cust_tbl(1).installment_begin_balance <> lns_financials.getRemainingBalance(p_loan_id) then
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'balance incorrect');
             FND_MESSAGE.Set_Name('LNS', 'LNS_BEGIN_BALANCE_INCORRECT');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
        end if;
      end if;
     */
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'validate custom row');
      validateCustomRow(p_custom_rec    => l_cust_tbl(i)
                       ,x_return_status => l_return_status
                       ,x_msg_count     => l_msg_count
                       ,x_msg_data      => l_msg_data);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           x_installment := i;
           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'invalid installment found #' || i);
           FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INSTALLMENT');
           FND_MESSAGE.SET_TOKEN('PARAMETER', 'INSTALLMENT');
           FND_MESSAGE.SET_TOKEN('VALUE', i);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      end if;

      -- check for consecutive installments
      if l_cust_tbl.exists(i+1) then
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'checking consecutive installments' || l_cust_tbl(i).payment_number || ' ' || l_cust_tbl(i+1).payment_number );
          if l_cust_tbl(i).payment_number + 1 <> l_cust_tbl(i+1).payment_number then
           FND_MESSAGE.Set_Name('LNS', 'LNS_NONSEQUENTIAL_INSTALLMENTS');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
          end if;
      end if;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'date checking');
      -- check for consecutive dates
      if l_date is null then
        l_date := l_cust_tbl(i).due_date;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'date is null');
      else

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'PASS: ' || i || 'p_cust_tbl(i).due_date is : ' || l_cust_tbl(i).due_date);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'l_date is: ' || l_date);
        if p_cust_tbl(i).due_date <= l_date then
           FND_MESSAGE.Set_Name('LNS', 'LNS_NONSEQUENTIAL_DATES');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        end if;
        l_date := l_cust_tbl(i).due_date;

      end if;

      l_amount := l_amount + l_cust_tbl(i).principal_amount;
  end loop;

  -- check if SUM of Prinicipal_Amount is equal to the Funded_Amount
  --  or requested_amount, etc... based on loan_Status
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'final balance check');

  --karamach bug5231822 l_loan_details.unbilled_principal does not return correct value for Direct loan
  --if l_amount <> l_loan_details.unbilled_principal  then
  if l_amount <> l_loan_details.remaining_balance  then
       logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'balance check incorrect');
       FND_MESSAGE.Set_Name('LNS', 'LNS_BALANCE_INCORRECT');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
  end if;

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'after final balance check');
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         --FND_MESSAGE.Set_Name('LNS', 'LNS_VALIDATE_CUSTOM_ERROR');
         --FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --FND_MESSAGE.Set_Name('LNS', 'LNS_VALIDATE_CUSTOM_ERROR');
         --FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         --FND_MESSAGE.Set_Name('LNS', 'LNS_VALIDATE_CUSTOM_ERROR');
         --FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
End;

/* procedure to validate a row in the LNS_CUSTOM_PAYMENT_SCHEDULE
||
||
||
||
|| */
procedure validateCustomRow(p_custom_rec        in CUSTOM_SCHED_TYPE
                            ,x_return_status    OUT NOCOPY VARCHAR2
                            ,x_msg_count        OUT NOCOPY NUMBER
                            ,x_msg_data         OUT NOCOPY VARCHAR2)
is
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_api_name              varchar2(30);

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_api_name := 'validateCustRow';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' validate One Row');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || p_custom_rec.PAYMENT_NUMBER   );
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || p_custom_rec.DUE_DATE         );
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || p_custom_rec.PRINCIPAL_AMOUNT );
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || p_custom_rec.INTEREST_AMOUNT );

     if p_custom_rec.due_Date is null then
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_DUE_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     elsif p_custom_rec.payment_number is null or p_custom_rec.payment_number < 1 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_PAYMENT_NUMBER');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     elsif p_custom_rec.PRINCIPAL_AMOUNT is not null and p_custom_rec.PRINCIPAL_AMOUNT < 0 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PRINICIPAL_AMOUNT_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     elsif p_custom_rec.INTEREST_AMOUNT is not null and p_custom_rec.INTEREST_AMOUNT < 0 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INTEREST_AMOUNT_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     elsif p_custom_rec.FEE_AMOUNT is not null and p_custom_rec.FEE_AMOUNT < 0 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_OTHER_AMOUNT_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     elsif p_custom_rec.OTHER_AMOUNT is not null and p_custom_rec.OTHER_AMOUNT < 0 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_OTHER_AMOUNT_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

END validateCustomRow;

procedure createCustomSched(P_CUSTOM_REC        IN CUSTOM_SCHED_TYPE
                           ,x_custom_sched_id  OUT NOCOPY NUMBER
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2)
is
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_custom_id             NUMBER;
    l_api_name              varchar2(25);

BEGIN
    l_api_name              := 'createCustomSched';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- dbms_output.put_line('createCustomAPI'      );
    LNS_CUSTOM_PAYMNT_SCHEDS_PKG.INSERT_ROW(x_custom_schedule_id => l_custom_id
                                           ,P_LOAN_ID            => P_CUSTOM_REC.LOAN_ID
                                           ,P_PAYMENT_NUMBER     => P_CUSTOM_REC.PAYMENT_NUMBER
                                           ,P_DUE_DATE           => P_CUSTOM_REC.DUE_DATE
                                           ,P_PRINCIPAL_AMOUNT   => P_CUSTOM_REC.PRINCIPAL_AMOUNT
                                           ,P_INTEREST_AMOUNT    => P_CUSTOM_REC.INTEREST_AMOUNT
--                                           ,P_PRINCIPAL_BALANCE  => P_CUSTOM_REC.PRINCIPAL_BALANCE
                                           ,P_FEE_AMOUNT         => P_CUSTOM_REC.FEE_AMOUNT
                                           ,P_OTHER_AMOUNT       => P_CUSTOM_REC.OTHER_AMOUNT
                                           ,p_INSTALLMENT_BEGIN_BALANCE => P_CUSTOM_REC.INSTALLMENT_BEGIN_BALANCE
                                           ,p_INSTALLMENT_END_BALANCE   => P_CUSTOM_REC.INSTALLMENT_END_BALANCE
                                           ,p_CURRENT_TERM_PAYMENT      => P_CUSTOM_REC.CURRENT_TERM_PAYMENT
                                           ,p_OBJECT_VERSION_NUMBER     => 1
                                           ,p_ATTRIBUTE_CATEGORY => P_CUSTOM_REC.ATTRIBUTE_CATEGORY
                                           ,p_ATTRIBUTE1         => P_CUSTOM_REC.ATTRIBUTE1
                                           ,p_ATTRIBUTE2         => P_CUSTOM_REC.ATTRIBUTE2
                                           ,p_ATTRIBUTE3         => P_CUSTOM_REC.ATTRIBUTE3
                                           ,p_ATTRIBUTE4         => P_CUSTOM_REC.ATTRIBUTE4
                                           ,p_ATTRIBUTE5         => P_CUSTOM_REC.ATTRIBUTE5
                                           ,p_ATTRIBUTE6         => P_CUSTOM_REC.ATTRIBUTE6
                                           ,p_ATTRIBUTE7         => P_CUSTOM_REC.ATTRIBUTE7
                                           ,p_ATTRIBUTE8         => P_CUSTOM_REC.ATTRIBUTE8
                                           ,p_ATTRIBUTE9         => P_CUSTOM_REC.ATTRIBUTE9
                                           ,p_ATTRIBUTE10        => P_CUSTOM_REC.ATTRIBUTE10
                                           ,p_ATTRIBUTE11        => P_CUSTOM_REC.ATTRIBUTE11
                                           ,p_ATTRIBUTE12        => P_CUSTOM_REC.ATTRIBUTE12
                                           ,p_ATTRIBUTE13        => P_CUSTOM_REC.ATTRIBUTE13
                                           ,p_ATTRIBUTE14        => P_CUSTOM_REC.ATTRIBUTE14
                                           ,p_ATTRIBUTE15        => P_CUSTOM_REC.ATTRIBUTE15
                                           ,p_ATTRIBUTE16        => P_CUSTOM_REC.ATTRIBUTE16
                                           ,p_ATTRIBUTE17        => P_CUSTOM_REC.ATTRIBUTE17
                                           ,p_ATTRIBUTE18        => P_CUSTOM_REC.ATTRIBUTE18
                                           ,p_ATTRIBUTE19        => P_CUSTOM_REC.ATTRIBUTE19
                                           ,p_ATTRIBUTE20        => P_CUSTOM_REC.ATTRIBUTE20
                                           ,p_LOCK_PRIN          => P_CUSTOM_REC.LOCK_PRIN
                                           ,p_LOCK_INT           => P_CUSTOM_REC.LOCK_INT);

    x_custom_sched_id := l_custom_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In createCustomSched: After call Insert_Row ID' || l_Custom_id );

END createCustomSched;

procedure updateCustomSched(P_CUSTOM_REC IN CUSTOM_SCHED_TYPE
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2)
is
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_object_version        NUMBER;

    l_api_name              varchar2(25);

BEGIN
    l_api_name              := 'updateCustomSched';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    LNS_UTILITY_PUB.GETOBJECTVERSION(P_TABLE_NAME             => 'LNS_CUSTOM_PAYMNT_SCHEDS'
                                    ,P_PRIMARY_KEY_NAME       => 'CUSTOM_SCHEDULE_ID'
                                    ,P_PRIMARY_KEY_VALUE      => P_CUSTOM_REC.CUSTOM_SCHEDULE_ID
                                    ,P_OBJECT_VERSION_NUMBER  => P_CUSTOM_REC.OBJECT_VERSION_NUMBER
                                    ,X_OBJECT_VERSION_NUMBER  => l_object_version
                                    ,X_MSG_COUNT              => l_msg_count
                                    ,X_MSG_DATA               => l_msg_data
                                    ,X_RETURN_STATUS          => l_return_status);

    LNS_CUSTOM_PAYMNT_SCHEDS_PKG.Update_Row(p_CUSTOM_SCHEDULE_ID    => P_CUSTOM_REC.CUSTOM_SCHEDULE_ID
                                           ,p_LOAN_ID               => P_CUSTOM_REC.LOAN_ID
                                           ,p_PAYMENT_NUMBER        => P_CUSTOM_REC.PAYMENT_NUMBER
                                           ,p_DUE_DATE              => P_CUSTOM_REC.DUE_DATE
                                           ,p_PRINCIPAL_AMOUNT      => P_CUSTOM_REC.PRINCIPAL_AMOUNT
                                           ,p_INTEREST_AMOUNT       => P_CUSTOM_REC.INTEREST_AMOUNT
--                                           ,p_PRINCIPAL_BALANCE     => P_CUSTOM_REC.PRINCIPAL_BALANCE
                                           ,p_FEE_AMOUNT            => P_CUSTOM_REC.FEE_AMOUNT
                                           ,p_OTHER_AMOUNT          => P_CUSTOM_REC.OTHER_AMOUNT
                                           ,p_INSTALLMENT_BEGIN_BALANCE => P_CUSTOM_REC.INSTALLMENT_BEGIN_BALANCE
                                           ,p_INSTALLMENT_END_BALANCE   => P_CUSTOM_REC.INSTALLMENT_END_BALANCE
                                           ,p_CURRENT_TERM_PAYMENT      => P_CUSTOM_REC.CURRENT_TERM_PAYMENT
                                           ,p_OBJECT_VERSION_NUMBER     => l_object_version
                                           ,p_ATTRIBUTE_CATEGORY        => P_CUSTOM_REC.ATTRIBUTE_CATEGORY
                                           ,p_ATTRIBUTE1                => P_CUSTOM_REC.ATTRIBUTE1
                                           ,p_ATTRIBUTE2                => P_CUSTOM_REC.ATTRIBUTE2
                                           ,p_ATTRIBUTE3                => P_CUSTOM_REC.ATTRIBUTE3
                                           ,p_ATTRIBUTE4                => P_CUSTOM_REC.ATTRIBUTE4
                                           ,p_ATTRIBUTE5                => P_CUSTOM_REC.ATTRIBUTE5
                                           ,p_ATTRIBUTE6                => P_CUSTOM_REC.ATTRIBUTE6
                                           ,p_ATTRIBUTE7                => P_CUSTOM_REC.ATTRIBUTE7
                                           ,p_ATTRIBUTE8                => P_CUSTOM_REC.ATTRIBUTE8
                                           ,p_ATTRIBUTE9                => P_CUSTOM_REC.ATTRIBUTE9
                                           ,p_ATTRIBUTE10               => P_CUSTOM_REC.ATTRIBUTE10
                                           ,p_ATTRIBUTE11               => P_CUSTOM_REC.ATTRIBUTE11
                                           ,p_ATTRIBUTE12               => P_CUSTOM_REC.ATTRIBUTE12
                                           ,p_ATTRIBUTE13               => P_CUSTOM_REC.ATTRIBUTE13
                                           ,p_ATTRIBUTE14               => P_CUSTOM_REC.ATTRIBUTE14
                                           ,p_ATTRIBUTE15               => P_CUSTOM_REC.ATTRIBUTE15
                                           ,p_ATTRIBUTE16               => P_CUSTOM_REC.ATTRIBUTE16
                                           ,p_ATTRIBUTE17               => P_CUSTOM_REC.ATTRIBUTE17
                                           ,p_ATTRIBUTE18               => P_CUSTOM_REC.ATTRIBUTE18
                                           ,p_ATTRIBUTE19               => P_CUSTOM_REC.ATTRIBUTE19
                                           ,p_ATTRIBUTE20               => P_CUSTOM_REC.ATTRIBUTE20
                                           ,p_LOCK_PRIN                 => P_CUSTOM_REC.LOCK_PRIN
                                           ,p_LOCK_INT                  => P_CUSTOM_REC.LOCK_INT);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In updateCustomSched: After call Insert_Row');

END updateCustomSched;




/*
This funciton will ensure the rows in the custom tbl are ordered by due date.
Will validate that due dates are unique
*/
procedure sortRowsByDate(p_custom_tbl in out nocopy LNS_CUSTOM_PUB.custom_tbl)

is
    l_custom_tbl LNS_CUSTOM_PUB.custom_tbl;
    i            number;
    j            number;
    l_temp       LNS_CUSTOM_PUB.custom_sched_type;

begin
    l_custom_tbl := p_custom_tbl;

    -- sort table by due_date
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Sorting by due date...');
    for i in REVERSE 1..l_custom_tbl.count loop
        for j in 1..(i-1) loop
            if l_custom_tbl(j).DUE_DATE > l_custom_tbl(j+1).DUE_DATE then
                l_temp := l_custom_tbl(j);
                l_custom_tbl(j) := l_custom_tbl(j+1);
                l_custom_tbl(j+1) := l_temp;
            elsif l_custom_tbl(j).DUE_DATE = l_custom_tbl(j+1).DUE_DATE then
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Several installments have the same due date.');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_DUE_DATE_DUPL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;
        end loop;
    end loop;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done sorting.');

    p_custom_tbl := l_custom_tbl;
end;




/*
This procedure will filter the custom tbl from deleted rows
*/
procedure filterCustSchedule(p_custom_tbl in out nocopy LNS_CUSTOM_PUB.custom_tbl)

is
    l_custom_tbl      LNS_CUSTOM_PUB.custom_tbl;
    l_new_custom_tbl  LNS_CUSTOM_PUB.custom_tbl;
    i                 number;
    j                 number;

begin
    l_custom_tbl := p_custom_tbl;
    j := 0;

    -- filtering table from deleted rows
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Filtering...');
    for i in 1..l_custom_tbl.count loop
        if l_custom_tbl(i).ACTION is null or l_custom_tbl(i).ACTION <> 'D' then
            j := j + 1;
            l_new_custom_tbl(j) := l_custom_tbl(i);
        end if;
    end loop;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done filtering.');

    p_custom_tbl := l_new_custom_tbl;
end;


/*
This procedure synchs rate schedule with new number of installments
*/
procedure synchRateSchedule(p_term_id in number, p_num_installments in number)

is

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_RATE_ID                       number;
    l_RATE                          number;
    l_BEGIN_INSTALLMENT             number;
    l_END_INSTALLMENT               number;
    i                               number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- cursor to load rate schedule
    cursor c_rate_sched(p_term_id NUMBER) IS
      select RATE_ID, CURRENT_INTEREST_RATE, BEGIN_INSTALLMENT_NUMBER, END_INSTALLMENT_NUMBER
      from lns_rate_schedules
      where term_id = p_term_id and
        END_DATE_ACTIVE is null and
        nvl(PHASE, 'TERM') = 'TERM'
      order by END_INSTALLMENT_NUMBER desc;

begin

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Synching rate schedule...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_term_id: ' || p_term_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_num_installments: ' || p_num_installments);

    -- finding right rate row and update it
    OPEN c_rate_sched(p_term_id);
    LOOP
        i := i + 1;
        FETCH c_rate_sched INTO
            l_RATE_ID,
            l_RATE,
            l_BEGIN_INSTALLMENT,
            l_END_INSTALLMENT;

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, i || ') Rate ' || l_RATE || ': ' || l_BEGIN_INSTALLMENT || ' - ' || l_END_INSTALLMENT);

        if p_num_installments > l_END_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);

            update lns_rate_schedules
            set END_INSTALLMENT_NUMBER = p_num_installments
            where term_id = p_term_id and
            RATE_ID = l_RATE_ID;

            exit;

        elsif p_num_installments >= l_BEGIN_INSTALLMENT and p_num_installments <= l_END_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);

            update lns_rate_schedules
            set END_INSTALLMENT_NUMBER = p_num_installments
            where term_id = p_term_id and
            RATE_ID = l_RATE_ID;

            exit;

        elsif p_num_installments < l_BEGIN_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Deleting this row');

            delete from lns_rate_schedules
            where term_id = p_term_id and
            RATE_ID = l_RATE_ID;

        end if;

    END LOOP;

    CLOSE c_rate_sched;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done synching');

end;



/*
This procedure synchs rate schedule with new number of installments in memory only, no changes to db
*/
procedure synchRateSchedule(p_rate_tbl IN OUT NOCOPY LNS_FINANCIALS.RATE_SCHEDULE_TBL, p_num_installments in number)

is

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_RATE_ID                       number;
    l_RATE                          number;
    l_BEGIN_INSTALLMENT             number;
    l_END_INSTALLMENT               number;
    i                               number;
    l_rate_tbl                      LNS_FINANCIALS.RATE_SCHEDULE_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

begin

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Synching rate schedule...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_num_installments: ' || p_num_installments);

    l_rate_tbl := p_rate_tbl;

    -- finding right rate row and update it
    for i in REVERSE 1..l_rate_tbl.count loop

        l_RATE := l_rate_tbl(i).ANNUAL_RATE;
        l_BEGIN_INSTALLMENT := l_rate_tbl(i).BEGIN_INSTALLMENT_NUMBER;
        l_END_INSTALLMENT := l_rate_tbl(i).END_INSTALLMENT_NUMBER;

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, i || ') Rate ' || l_RATE || ': ' || l_BEGIN_INSTALLMENT || ' - ' || l_END_INSTALLMENT);

        if p_num_installments > l_END_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);
            l_rate_tbl(i).END_INSTALLMENT_NUMBER := p_num_installments;

            exit;

        elsif p_num_installments >= l_BEGIN_INSTALLMENT and p_num_installments <= l_END_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);
            l_rate_tbl(i).END_INSTALLMENT_NUMBER := p_num_installments;

            exit;

        elsif p_num_installments < l_BEGIN_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Deleting this row');
            l_rate_tbl.delete(i);

        end if;

    END LOOP;

    p_rate_tbl := l_rate_tbl;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done synching');

end;



-- This function returns payment schedule record
-- introduced for bug 7319358
function getPayment(P_LOAN_ID IN NUMBER, P_PAYMENT_NUMBER IN NUMBER) return LNS_FIN_UTILS.PAYMENT_SCHEDULE
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'getPayment';
    l_payment_schedule              LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_payment                       LNS_FIN_UTILS.PAYMENT_SCHEDULE;
    i                               number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_PAYMENT_NUMBER: ' || P_PAYMENT_NUMBER);

    l_payment_schedule := buildCustomPaySchedule(P_LOAN_ID);
    for i in 1..l_payment_schedule.count loop
        if P_PAYMENT_NUMBER = i then
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Found payment ' || P_PAYMENT_NUMBER);
            l_payment := l_payment_schedule(i);
            exit;
        end if;
    end loop;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

    return l_payment;
END;



function getLoanDetails(p_loan_id in number
                       ,p_based_on_terms in varchar2) return LNS_CUSTOM_PUB.LOAN_DETAILS_REC

is

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'getLoanDetails';
    l_loan_Details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_billed_principal              number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
  CURSOR c_loan_details(p_Loan_id NUMBER, p_based_on_terms varchar2) IS
  SELECT h.loan_id
        ,t.amortization_frequency
        ,t.loan_payment_frequency
        ,trunc(h.loan_start_date)
        ,h.funded_amount
		,h.requested_amount
        ,lns_financials.getRemainingBalance(p_loan_id)
        ,trunc(h.loan_maturity_date)
        ,decode(p_based_on_terms, 'CURRENT', LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id, 'TERM'), 0)
--        ,decode(p_based_on_terms, 'CURRENT', LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(p_loan_id), -1)
        ,decode(nvl(t.day_count_method, 'PERIODIC30_360'), 'PERIODIC30_360', '30/360', t.day_count_method)
        ,nvl(h.custom_payments_flag, 'N')
        ,h.loan_status
        ,h.loan_currency
        ,curr.precision
--        ,nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')
        ,decode(p_based_on_terms,
            'CURRENT', decode(nvl(h.custom_payments_flag, 'N'), 'Y', nvl(t.PAYMENT_CALC_METHOD, 'CUSTOM'),
                                                                'N', nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')),
            decode(nvl(h.custom_payments_flag, 'N'), 'Y', nvl(t.ORIG_PAY_CALC_METHOD, 'CUSTOM'),
                                                     'N', nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT'))
         )
        ,t.CALCULATION_METHOD
        ,t.INTEREST_COMPOUNDING_FREQ
        ,nvl(t.CUSTOM_CALC_METHOD, 'NONE')
--        ,nvl(t.CUSTOM_CALC_METHOD, decode(nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT'), 'EQUAL_PAYMENT', 'EQUAL_PAYMENT',
--          'EQUAL_PAYMENT_STANDARD', 'EQUAL_PAYMENT', 'EQUAL_PRINCIPAL', 'EQUAL_PRINCIPAL', 'SEPARATE_SCHEDULES', 'EQUAL_PRINCIPAL'))
        ,t.ORIG_PAY_CALC_METHOD
        ,t.RATE_TYPE                        RATE_TYPE
        ,t.CEILING_RATE                     TERM_CEILING_RATE
        ,t.FLOOR_RATE                       TERM_FLOOR_RATE
        ,t.PERCENT_INCREASE                 TERM_PERCENT_INCREASE
        ,t.PERCENT_INCREASE_LIFE            TERM_PERCENT_INCREASE_LIFE
        ,t.FIRST_PERCENT_INCREASE           TERM_FIRST_PERCENT_INCREASE
        ,t.INDEX_RATE_ID                    TERM_INDEX_RATE_ID
        ,t.TERM_PROJECTED_RATE INITIAL_INTEREST_RATE
        ,nvl(lns_fin_utils.getActiveRate(h.loan_id), t.TERM_PROJECTED_RATE)            LAST_INTEREST_RATE
        ,nvl(t.FIRST_RATE_CHANGE_DATE, t.NEXT_RATE_CHANGE_DATE) FIRST_RATE_CHANGE_DATE
        ,t.NEXT_RATE_CHANGE_DATE             NEXT_RATE_CHANGE_DATE
        ,t.TERM_PROJECTED_RATE              TERM_PROJECTED_RATE
        ,nvl(t.PENAL_INT_RATE, 0)
        ,nvl(t.PENAL_INT_GRACE_DAYS, 0)
        ,nvl(t.REAMORTIZE_ON_FUNDING, 'REST')

    FROM lns_loan_headers_all h
        ,lns_terms t
        ,fnd_currencies curr
   WHERE h.loan_id = p_loan_id
     AND h.loan_id = t.loan_id
     AND curr.currency_code = h.loan_currency;

    cursor c_balanceInfo(p_loan_id NUMBER, p_phase varchar2) IS
    select  nvl(sum(amort.PRINCIPAL_AMOUNT),0)                       -- billed principal
        ,nvl(sum(amort.PRINCIPAL_REMAINING),0)  -- unpaid principal
        ,nvl(sum(amort.INTEREST_REMAINING),0)  -- unpaid interest
    from LNS_AM_SCHEDS_V amort
    where amort.Loan_id = p_loan_id
    and amort.REVERSED_CODE = 'N'
    and amort.phase = p_phase;

   -- cursor to get last bill due date
   cursor c_due_date(p_loan_id NUMBER) IS
   select trunc(max(DUE_DATE))
     from lns_amortization_scheds
    where loan_id = p_loan_id
      and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
      --and parent_amortization_id is null
      and REAMORTIZATION_AMOUNT is null
      and nvl(phase, 'TERM') = 'TERM';

begin

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || '+');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Input:');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_based_on_terms: ' || p_based_on_terms);

    OPEN c_loan_details(p_loan_id, p_based_on_terms);
    FETCH c_loan_details INTO
        l_loan_details.loan_id
        ,l_loan_Details.amortization_frequency
        ,l_loan_Details.payment_frequency
        ,l_loan_Details.loan_start_date
        ,l_loan_details.funded_amount
        ,l_loan_details.requested_amount
        ,l_loan_details.remaining_balance
        ,l_loan_details.maturity_Date
        ,l_loan_details.last_installment_billed
        ,l_loan_details.day_count_method
        ,l_loan_details.custom_schedule
        ,l_loan_details.loan_status
        ,l_loan_details.loan_currency
        ,l_loan_details.currency_precision
        ,l_loan_details.PAYMENT_CALC_METHOD
        ,l_loan_details.CALCULATION_METHOD
        ,l_loan_details.INTEREST_COMPOUNDING_FREQ
        ,l_loan_details.CUSTOM_CALC_METHOD
        ,l_loan_details.ORIG_PAY_CALC_METHOD
        ,l_loan_details.RATE_TYPE                    -- fixed or variable
        ,l_loan_details.TERM_CEILING_RATE            -- term ceiling rate
        ,l_loan_details.TERM_FLOOR_RATE              -- term floor rate
        ,l_loan_details.TERM_ADJ_PERCENT_INCREASE    -- term percentage increase btwn adjustments
        ,l_loan_details.TERM_LIFE_PERCENT_INCREASE   -- term lifetime max adjustment for interest
        ,l_loan_details.TERM_FIRST_PERCENT_INCREASE  -- term first percentage increase
        ,l_loan_details.TERM_INDEX_RATE_ID
        ,l_loan_details.INITIAL_INTEREST_RATE        -- current phase only
        ,l_loan_details.LAST_INTEREST_RATE           -- current phase only
        ,l_loan_details.FIRST_RATE_CHANGE_DATE       -- current phase only
        ,l_loan_details.NEXT_RATE_CHANGE_DATE        -- current phase only
        ,l_loan_details.TERM_PROJECTED_INTEREST_RATE -- term projected interest rate
        ,l_loan_details.PENAL_INT_RATE
        ,l_loan_details.PENAL_INT_GRACE_DAYS
        ,l_loan_details.REAMORTIZE_ON_FUNDING;
    close c_loan_details;

    -- use this part of the procedure to differentiate between
    -- elements that are calculated differently for current and original
    -- amortization
    if p_based_on_terms = 'CURRENT' then

		Begin
            -- get balance information
            open c_balanceInfo(p_loan_id, 'TERM');
            fetch c_balanceInfo into
                  l_billed_principal
                 ,l_loan_details.unpaid_principal
                 ,l_loan_details.UNPAID_INTEREST;
            close c_balanceInfo;
            l_loan_details.billed_principal := l_billed_principal;
            l_loan_details.unbilled_principal := l_loan_details.funded_amount - l_billed_principal;
        Exception
            when no_data_found then
                   l_loan_details.unpaid_principal            := 0;
                   l_loan_details.billed_principal            := 0;
                   l_loan_details.unbilled_principal          := l_loan_details.funded_amount;
                   l_loan_details.UNPAID_INTEREST             := 0;
        End;

        -- get last due date
    	Begin
             open c_due_date(p_loan_id);
             fetch c_due_date into l_loan_details.LAST_DUE_DATE;
             close c_due_date;
        Exception
            when no_data_found then
                   l_loan_details.LAST_DUE_DATE               := null;
		End;

    else
        l_loan_details.unpaid_principal            := 0;
        l_loan_details.billed_principal            := 0;
        l_loan_details.unbilled_principal          := l_loan_details.funded_amount;
        l_loan_details.UNPAID_INTEREST             := 0;
        l_loan_details.LAST_DUE_DATE               := null;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Loan details:');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' custom_schedule:       ' || l_loan_details.custom_schedule);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' amortization_frequency:       ' || l_loan_details.amortization_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' payment_frequency:            ' || l_loan_details.payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' loan start date:              ' || l_loan_details.loan_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' funded_amount:                ' || l_loan_details.funded_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' remaining balance:            ' || l_loan_details.remaining_balance);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' maturity_date:                ' || l_loan_details.maturity_Date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' last installment billed:      ' || l_loan_details.last_installment_billed);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' day Count method:             ' || l_loan_details.day_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' loan_status:                  ' || l_loan_details.loan_status);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' loan_currency:                ' || l_loan_details.loan_currency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' currency_precision:           ' || l_loan_details.currency_precision);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' PAYMENT_CALC_METHOD:          ' || l_loan_details.PAYMENT_CALC_METHOD);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' CALCULATION_METHOD:           ' || l_loan_details.CALCULATION_METHOD);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' INTEREST_COMPOUNDING_FREQ:    ' || l_loan_details.INTEREST_COMPOUNDING_FREQ);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' unpaid_principal:             ' || l_loan_details.unpaid_principal);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' unbilled_principal:           ' || l_loan_details.unbilled_principal);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' UNPAID_INTEREST:              ' || l_loan_details.UNPAID_INTEREST);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' LAST_DUE_DATE:                ' || l_loan_details.LAST_DUE_DATE);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' CUSTOM_CALC_METHOD:           ' || l_loan_details.CUSTOM_CALC_METHOD);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ORIG_PAY_CALC_METHOD:         ' || l_loan_details.ORIG_PAY_CALC_METHOD);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || '-');

    return l_loan_details;

Exception
    When No_Data_Found then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LOAN ID: ' || p_loan_id || ' not found');
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_LOAN_ID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    When Others then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Err: ' || sqlerrm);
        RAISE FND_API.G_EXC_ERROR;

end getLoanDetails;



-- This procedure loads custom schedule from db
procedure loadCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        X_AMORT_METHOD      OUT NOCOPY      VARCHAR2,
        X_CUSTOM_TBL        OUT NOCOPY      LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'loadCustomSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_custom_tbl                    LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_temp_row                      LNS_CUSTOM_PUB.custom_sched_type;
    l_amort_tbl                     LNS_FINANCIALS.AMORTIZATION_TBL;
    i                               number;
    j                               number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- cursor to load custom schedule
    -- fix for bug 7026226: default PRINCIPAL_AMOUNT and INTEREST_AMOUNT to 0 if they are null
    cursor c_load_sched(p_loan_id NUMBER, p_begin_installment NUMBER) IS
    select
        CUSTOM_SCHEDULE_ID,
        LOAN_ID,
        PAYMENT_NUMBER,
        DUE_DATE,
        nvl(PRINCIPAL_AMOUNT, 0),
        nvl(INTEREST_AMOUNT, 0),
        nvl(FEE_AMOUNT, 0),
        nvl(OTHER_AMOUNT, 0),
        nvl(LOCK_PRIN, 'Y'),
        nvl(LOCK_INT, 'Y')
    from LNS_CUSTOM_PAYMNT_SCHEDS
    where loan_id = p_loan_id
    and PAYMENT_NUMBER > p_begin_installment
    order by PAYMENT_NUMBER;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT loadCustomSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_BASED_ON_TERMS: ' || P_BASED_ON_TERMS);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BASED_ON_TERMS is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'BASED_ON_TERMS');
        FND_MESSAGE.SET_TOKEN('VALUE', P_BASED_ON_TERMS);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => p_based_on_terms);

    if (l_loan_details.CUSTOM_SCHEDULE = 'N' or
       (l_loan_details.CUSTOM_SCHEDULE = 'Y' and l_loan_details.loan_status <> 'INCOMPLETE' and
        p_based_on_terms <> 'CURRENT' and l_loan_details.ORIG_PAY_CALC_METHOD is not null))
    then

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_FINANCIALS.runAmortization...');
        LNS_FINANCIALS.runAmortization(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_LOAN_ID               => P_LOAN_ID,
            P_BASED_ON_TERMS        => P_BASED_ON_TERMS,
            x_amort_tbl             => l_amort_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Schedule from LNS_FINANCIALS.runAmortization:');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PN   DD        PRIN     LP  INT      LI  FEE    OTH    ID');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '---  --------  -------  --  -------  --  -----  -----  ------');

        j := 0;
        for i in 1..l_amort_tbl.count loop

            if l_amort_tbl(i).INSTALLMENT_NUMBER > 0 then -- excluding 0-th installment from customization
                j := j + 1;
                l_custom_tbl(j).LOAN_ID := P_LOAN_ID;
                l_custom_tbl(j).PAYMENT_NUMBER := l_amort_tbl(i).INSTALLMENT_NUMBER;
                l_custom_tbl(j).DUE_DATE := l_amort_tbl(i).DUE_DATE;
                l_custom_tbl(j).PRINCIPAL_AMOUNT := l_amort_tbl(i).PRINCIPAL_AMOUNT;
                l_custom_tbl(j).LOCK_PRIN := 'Y';
                l_custom_tbl(j).INTEREST_AMOUNT := l_amort_tbl(i).INTEREST_AMOUNT;
                l_custom_tbl(j).LOCK_INT := 'Y';
                l_custom_tbl(j).FEE_AMOUNT := l_amort_tbl(i).FEE_AMOUNT;
                l_custom_tbl(j).OTHER_AMOUNT := l_amort_tbl(i).OTHER_AMOUNT;
                l_custom_tbl(j).ACTION := 'I';

                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                    l_custom_tbl(j).PAYMENT_NUMBER || '  ' ||
                    l_custom_tbl(j).DUE_DATE || '  ' ||
                    l_custom_tbl(j).PRINCIPAL_AMOUNT || '  ' ||
                    l_custom_tbl(j).LOCK_PRIN || '  ' ||
                    l_custom_tbl(j).INTEREST_AMOUNT || '  ' ||
                    l_custom_tbl(j).LOCK_INT || '  ' ||
                    l_custom_tbl(j).FEE_AMOUNT || '  ' ||
                    l_custom_tbl(j).OTHER_AMOUNT || '  ' ||
                    l_custom_tbl(j).CUSTOM_SCHEDULE_ID);
            end if;

        end loop;

    else

        i := 0;
        OPEN c_load_sched(p_loan_id, l_loan_details.LAST_INSTALLMENT_BILLED);

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Loading custom schedule from LNS_CUSTOM_PAYMNT_SCHEDS:');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PN   DD        PRIN     LP  INT      LI  FEE    OTH    ID');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '---  --------  -------  --  -------  --  -----  -----  ------');

        LOOP

            FETCH c_load_sched INTO
                l_temp_row.CUSTOM_SCHEDULE_ID,
                l_temp_row.LOAN_ID,
                l_temp_row.PAYMENT_NUMBER,
                l_temp_row.DUE_DATE,
                l_temp_row.PRINCIPAL_AMOUNT,
                l_temp_row.INTEREST_AMOUNT,
                l_temp_row.FEE_AMOUNT,
                l_temp_row.OTHER_AMOUNT,
                l_temp_row.LOCK_PRIN,
                l_temp_row.LOCK_INT;
            exit when c_load_sched%NOTFOUND;

            i := i + 1;
            l_custom_tbl(i) := l_temp_row;

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                   l_custom_tbl(i).PAYMENT_NUMBER || '  ' ||
                   l_custom_tbl(i).DUE_DATE || '  ' ||
                   l_custom_tbl(i).PRINCIPAL_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_PRIN || '  ' ||
                   l_custom_tbl(i).INTEREST_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_INT || '  ' ||
                   l_custom_tbl(i).FEE_AMOUNT || '  ' ||
                   l_custom_tbl(i).OTHER_AMOUNT || '  ' ||
                   l_custom_tbl(i).CUSTOM_SCHEDULE_ID);

        END LOOP;
        CLOSE c_load_sched;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Recalculating schedule...');
    LNS_CUSTOM_PUB.recalcCustomSchedule(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT		        => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID               => P_LOAN_ID,
        P_AMORT_METHOD          => l_loan_details.CUSTOM_CALC_METHOD,
        P_BASED_ON_TERMS        => P_BASED_ON_TERMS,
        P_CUSTOM_TBL            => l_custom_tbl,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    IF l_return_status <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    X_CUSTOM_TBL := l_CUSTOM_TBL;
    X_AMORT_METHOD := l_loan_details.CUSTOM_CALC_METHOD;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO loadCustomSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO loadCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO loadCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



-- This procedure recalculates custom schedule
procedure recalcCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'recalcCustomSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_custom_tbl                    LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_temp_row                      LNS_CUSTOM_PUB.custom_sched_type;
    l_rate_tbl                      LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_rate_details                  LNS_FINANCIALS.INTEREST_RATE_REC;

    l_compound_freq                 varchar2(30);
    l_remaining_balance_actual      number;
    l_remaining_balance_theory      number;
--    l_remaining_balance_theory1     number;
    l_last_installment_billed       number;
    l_calc_method                   varchar2(30);
    l_day_count_method              varchar2(30);
    l_unbilled_principal            number;
    l_num_unlocked_prin             number;
    --l_pay_in_arrears                boolean;
    l_period_begin_date             date;
    l_period_end_date               date;
    l_precision                     number;
    l_periodic_rate                 number;
    l_periodic_principal            number;
    l_annualized_rate               number;
    l_locked_prin                   number;
    l_unpaid_amount                 number;
    l_payment_freq                  varchar2(30);
    l_previous_annualized           number;
    l_rate_to_calculate             number;
    l_amortization_intervals        number;
    l_periodic_payment              number;
    l_unpaid_principal              number;
    l_unpaid_interest               number;
    l_num_installments              number;
    i                               number;
    l_installment                   number;
    l_raw_rate                      number;
    l_norm_interest                 number;
    l_add_prin_interest             number;
    l_add_int_interest              number;
    l_add_start_date                date;
    l_add_end_date                  date;
    l_penal_prin_interest           number;
    l_penal_int_interest            number;
    l_penal_interest                number;
    l_prev_grace_end_date           date;
    l_payment                       LNS_FIN_UTILS.PAYMENT_SCHEDULE;

     -- for fees
    l_fee_structures                LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fee_structures           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
--    l_orig_fee_structures1          LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures       LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_funding_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fees_tbl                 LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                 LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fees_tbl                      LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_funding_fees_tbl              LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                 LNS_FEE_ENGINE.FEE_BASIS_TBL;
    l_fee_amount                    number;
    l_other_amount                  number;
    l_manual_fee_amount             number;
    l_disb_header_id                number;
    l_billed                        varchar2(1);
    n                               number;
    l_sum_periodic_principal         number;
    l_date1                          date;
    l_billed_principal               number;
    l_detail_int_calc_flag           boolean;
    l_increased_amount               number;
    l_increased_amount1              number;
    l_begin_funded_amount            number;
    l_end_funded_amount              number;
    l_increase_amount_instal         number;
    l_prev_increase_amount_instal    number;
    l_begin_funded_amount_new        number;
    l_fund_sched_count               number;
    l_wtd_balance                    number;
    l_balance1                       number;
    l_balance2                       number;

    l_norm_int_detail_str            varchar2(2000);
    l_add_prin_int_detail_str        varchar2(2000);
    l_add_int_int_detail_str         varchar2(2000);
    l_penal_prin_int_detail_str      varchar2(2000);
    l_penal_int_int_detail_str       varchar2(2000);
    l_penal_int_detail_str           varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- manual fees
    cursor c_manual_fees(p_loan_id number, p_installment number) is
    select sum(nvl(fee_amount,0))
      from lns_fee_schedules sch,
           lns_fees fees
     where sch.active_flag = 'Y'
       and sch.billed_flag = 'N'
       and fees.fee_id = sch.fee_id
       and ((fees.fee_category = 'MANUAL')
        OR (fees.fee_category = 'EVENT' AND fees.fee_type = 'EVENT_LATE_CHARGE'))
       and sch.loan_id = p_loan_id
       and fee_installment = p_installment
       and sch.phase = 'TERM';

    -- get last bill date
    cursor c_get_last_bill_date(p_loan_id number, p_installment_number number)  is
        select ACTIVITY_DATE
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and ACTIVITY_CODE in ('BILLING', 'START');

    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'TERM';

    cursor c_get_funded_amount(p_loan_id number, p_installment_number number)  is
        select FUNDED_AMOUNT
        from LNS_AMORTIZATION_SCHEDS
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and nvl(PHASE, 'TERM') = 'TERM';

    cursor c_fund_sched_exist(p_loan_id number)  is
        select decode(loan.loan_class_code,
            'DIRECT', (select count(1) from lns_disb_headers where loan_id = p_loan_id and status is null and PAYMENT_REQUEST_DATE is not null),
            'ERS', (select count(1) from lns_loan_lines where loan_id = p_loan_id and (status is null or status = 'PENDING') and end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT recalcCustomSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_BASED_ON_TERMS: ' || P_BASED_ON_TERMS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_AMORT_METHOD: ' || P_AMORT_METHOD);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BASED_ON_TERMS is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'BASED_ON_TERMS');
        FND_MESSAGE.SET_TOKEN('VALUE', P_BASED_ON_TERMS);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_AMORT_METHOD is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'AMORT_METHOD');
        FND_MESSAGE.SET_TOKEN('VALUE', P_AMORT_METHOD);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_CUSTOM_TBL := P_CUSTOM_TBL;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input Schedule:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PN   DD        RATE  BB      UP      UI      PAY     PRIN    LP  INT     LI  EB     ACT');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '---  --------  ----  ------  ------  ------  ------  ------  --  ------  -- ------  ---');
    for i in 1..l_custom_tbl.count loop

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                   l_custom_tbl(i).PAYMENT_NUMBER || '  ' ||
                   l_custom_tbl(i).DUE_DATE || '  ' ||
                   l_custom_tbl(i).INTEREST_RATE || '  ' ||
                   l_custom_tbl(i).INSTALLMENT_BEGIN_BALANCE || '  ' ||
                   l_custom_tbl(i).UNPAID_PRIN || '  ' ||
                   l_custom_tbl(i).UNPAID_INT || '  ' ||
                   l_custom_tbl(i).CURRENT_TERM_PAYMENT || '  ' ||
                   l_custom_tbl(i).PRINCIPAL_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_PRIN || '  ' ||
                   l_custom_tbl(i).INTEREST_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_INT || '  ' ||
                   l_custom_tbl(i).INSTALLMENT_END_BALANCE || '  ' ||
                   l_custom_tbl(i).ACTION);
    end loop;

    filterCustSchedule(l_custom_tbl);
    if l_custom_tbl.count = 0 then

        -- fix for bug 7217204
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Custom schedule is empty. Returning.');
        return;
/*
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Custom amortization is empty.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CUST_AMORT_EMPTY');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
*/
    end if;

    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => p_based_on_terms);
    sortRowsByDate(l_custom_tbl);

    l_remaining_balance_theory      := l_loan_details.requested_amount; --remaining_balance;
--    l_remaining_balance_theory1     := l_loan_details.remaining_balance;
    l_remaining_balance_actual      := l_loan_details.remaining_balance;
    l_last_installment_billed       := l_loan_details.last_installment_billed;
    l_calc_method                   := l_loan_details.CALCULATION_METHOD;
    l_day_count_method              := l_loan_details.day_count_method;
    l_unbilled_principal            := l_loan_details.unbilled_principal;
    l_billed_principal              := l_loan_details.billed_principal;
    l_unpaid_amount                 := l_loan_details.unpaid_principal + l_loan_details.UNPAID_INTEREST;
    l_compound_freq                 := l_loan_details.INTEREST_COMPOUNDING_FREQ;
    l_payment_freq                  := l_loan_details.PAYMENT_FREQUENCY;
    --l_pay_in_arrears                := l_loan_details.pay_in_arrears_boolean;
    l_precision                     := l_loan_details.currency_precision;
    l_previous_annualized           := -1;
    l_unpaid_principal              := l_loan_details.unpaid_principal;
    l_unpaid_interest               := l_loan_details.UNPAID_INTEREST;
    l_sum_periodic_principal        := 0;

    l_num_unlocked_prin := 0;
    l_locked_prin := 0;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Sorted table:');
    for i in 1..l_custom_tbl.count loop

        if l_custom_tbl(i).DUE_DATE < l_loan_details.loan_start_date then
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Installment due date cannot be earlier then loan start date.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EARLIER_LN_START_DATE');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_loan_details.LAST_DUE_DATE is not null then
            if l_custom_tbl(i).DUE_DATE <= l_loan_details.LAST_DUE_DATE then
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Installment due date cannot be earlier or equal to due date of the last billed installment.');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_EARLIER_LAST_BILLED_DD');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;
        end if;

        if l_custom_tbl(i).DUE_DATE > l_loan_details.maturity_Date then

            if i = l_custom_tbl.count then  -- fix for bug 6920780: if its last installment and due date is beyond maturity date - set it to maturity date
                l_custom_tbl(i).DUE_DATE := l_loan_details.maturity_Date;
            else
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Installment due date cannot be later then loan maturity date.');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_LATER_LN_MATUR_DATE');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

        end if;

        l_custom_tbl(i).PAYMENT_NUMBER := l_last_installment_billed + i;

        -- fix for bug 7026226: default PRINCIPAL_AMOUNT if its null
        if l_custom_tbl(i).PRINCIPAL_AMOUNT is null then
            l_custom_tbl(i).PRINCIPAL_AMOUNT := 0;
        end if;

        -- fix for bug 7026226: default INTEREST_AMOUNT if its null
        if l_custom_tbl(i).INTEREST_AMOUNT is null then
            l_custom_tbl(i).INTEREST_AMOUNT := 0;
        end if;

        -- default LOCK_PRIN
	-- fix for bug 8309391 - let to lock last prin row
        if l_custom_tbl(i).LOCK_PRIN is null then
            l_custom_tbl(i).LOCK_PRIN := 'Y';
        -- elsif i = l_custom_tbl.count then
        --    l_custom_tbl(i).LOCK_PRIN := 'N';
        end if;

        -- default LOCK_INT
        if l_custom_tbl(i).LOCK_INT is null then
            l_custom_tbl(i).LOCK_INT := 'Y';
        --elsif i = l_custom_tbl.count then
        --    l_custom_tbl(i).LOCK_INT := 'N';
        end if;

        -- count number of unlocked principals and sum of locked principals
        if l_custom_tbl(i).LOCK_PRIN = 'N' then
            l_num_unlocked_prin := l_num_unlocked_prin + 1;
        elsif l_custom_tbl(i).LOCK_PRIN = 'Y' then
            l_locked_prin := l_locked_prin + l_custom_tbl(i).PRINCIPAL_AMOUNT;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_custom_tbl(' || i || ').DUE_DATE: ' || l_custom_tbl(i).DUE_DATE);

    end loop;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Number of unlocked principals: ' || l_num_unlocked_prin);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Sum of locked principals: ' || l_locked_prin);

    -- get rate schedule
    l_rate_tbl      := lns_financials.getRateSchedule(p_loan_id, 'TERM');

    -- synch rate schedule with current custom schedule
    l_num_installments := l_custom_tbl(l_custom_tbl.count).PAYMENT_NUMBER;
    synchRateSchedule(l_rate_tbl, l_num_installments);

    --getting fees
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'getting fee structures');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting origination1 fee structures 2');
    l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                            ,p_fee_category => 'EVENT'
                                                            ,p_fee_type     => 'EVENT_ORIGINATION'
                                                            ,p_installment  => null
                                                            ,p_phase        => 'TERM'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'origination1 structures count is ' || l_orig_fee_structures.count);

    -- filtering out origination fees based on p_based_on_terms
    n := 0;
    for m in 1..l_orig_fee_structures.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Fee = ' || l_orig_fee_structures(m).FEE_ID);
        l_billed := null;
        open c_orig_fee_billed(p_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
        fetch c_orig_fee_billed into l_billed;
        close c_orig_fee_billed;

        if l_billed is null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
            n := n + 1;
            l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
        end if;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting recurring fee structures');
    l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                        ,p_fee_category => 'RECUR'
                                                        ,p_fee_type     => null
                                                        ,p_installment  => null
                                                        ,p_phase        => 'TERM'
                                                        ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fee structures count is ' || l_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting memo fee structures');
    l_memo_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                            ,p_fee_category => 'MEMO'
                                                            ,p_fee_type     => null
                                                            ,p_installment  => null
                                                            ,p_phase        => 'TERM'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'memo fee structures count is ' || l_memo_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
    l_funding_fee_structures  := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => p_loan_id
                                                                            ,p_installment_no => null
                                                                            ,p_phase          => 'TERM'
                                                                            ,p_disb_header_id => null
                                                                            ,p_fee_id         => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding fee structures count is ' || l_funding_fee_structures.count);

    if p_based_on_terms <> 'CURRENT' then
        open c_fund_sched_exist(p_loan_id);
        fetch c_fund_sched_exist into l_fund_sched_count;
        close c_fund_sched_exist;

        if l_fund_sched_count = 0 then
            l_remaining_balance_theory := l_loan_details.requested_amount;
        else
            l_remaining_balance_theory := LNS_FINANCIALS.getFundedAmount(p_loan_id, l_loan_details.LOAN_START_DATE, p_based_on_terms);
        end if;
    else
        l_remaining_balance_theory := LNS_FINANCIALS.getFundedAmount(p_loan_id, l_loan_details.LOAN_START_DATE, p_based_on_terms);
    end if;

    if p_based_on_terms = 'CURRENT' and l_last_installment_billed > 0 then
        l_begin_funded_amount := 0;
        open c_get_funded_amount(p_loan_id, l_last_installment_billed);
        fetch c_get_funded_amount into l_begin_funded_amount;
        close c_get_funded_amount;
    else
        l_begin_funded_amount := 0;  --l_remaining_balance_theory;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

    l_increase_amount_instal := -1;

    for i in 1..l_custom_tbl.count loop

        --i := i + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Row ' || i);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_NUMBER ' || l_custom_tbl(i).PAYMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '----------------------------------');

        -- get start and end dates
        if l_custom_tbl(i).PAYMENT_NUMBER = (l_last_installment_billed + 1) then
            if l_custom_tbl(i).PAYMENT_NUMBER = 0 or l_custom_tbl(i).PAYMENT_NUMBER = 1 then
                l_period_begin_date := l_loan_details.LOAN_START_DATE;
            else
                l_period_begin_date := l_loan_details.LAST_DUE_DATE;
            end if;
        else
            l_period_begin_date := l_custom_tbl(i-1).DUE_DATE;
        end if;
        l_period_end_date := l_custom_tbl(i).DUE_DATE;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period: ' || l_period_begin_date || ' - ' || l_period_end_date);

        l_custom_tbl(i).PERIOD_START_DATE := l_period_begin_date;
        l_custom_tbl(i).PERIOD_END_DATE := l_period_end_date;
        l_custom_tbl(i).PERIOD := l_period_begin_date || ' - ' || (l_period_end_date-1);

        -- get rate
        l_rate_details := lns_financials.getRateDetails(p_installment => l_custom_tbl(i).PAYMENT_NUMBER
                                                        ,p_rate_tbl   => l_rate_tbl);

        l_annualized_rate := l_rate_details.annual_rate;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'annualized_rate: ' || l_annualized_rate);
        l_custom_tbl(i).INTEREST_RATE := l_annualized_rate;

        l_norm_interest := 0;
        l_add_prin_interest := 0;
        l_add_int_interest := 0;
        l_penal_prin_interest := 0;
        l_penal_int_interest := 0;
        l_penal_interest := 0;
        l_norm_int_detail_str := null;
        l_add_prin_int_detail_str := null;
        l_add_int_int_detail_str := null;
        l_penal_prin_int_detail_str := null;
        l_penal_int_int_detail_str := null;
        l_penal_int_detail_str := null;
        l_detail_int_calc_flag := false;
        l_increased_amount := 0;
        l_increased_amount1:= 0;
        l_prev_increase_amount_instal := l_increase_amount_instal;

        if l_fund_sched_count > 0 or p_based_on_terms = 'CURRENT' then

            if l_custom_tbl(i).PAYMENT_NUMBER = (l_last_installment_billed + 1) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_custom_tbl(i).PAYMENT_NUMBER = (l_last_installment_billed + 1)');

                if l_loan_details.LOAN_STATUS <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_custom_tbl(i).PERIOD_START_DATE);
                    l_begin_funded_amount_new := LNS_FINANCIALS.getFundedAmount(p_loan_id, l_custom_tbl(i).PERIOD_START_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_custom_tbl(i).PERIOD_END_DATE-1));
                    l_end_funded_amount := LNS_FINANCIALS.getFundedAmount(p_loan_id, (l_custom_tbl(i).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := i;
                        else
                            if l_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := i + 1;
                            elsif l_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := i;
                            end if;
                        end if;

                    elsif l_begin_funded_amount_new > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new > l_begin_funded_amount');
                        l_increase_amount_instal := i;
                    end if;

                    l_detail_int_calc_flag := true;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_custom_tbl(i).PERIOD_START_DATE-1));
                    l_begin_funded_amount := LNS_FINANCIALS.getFundedAmount(p_loan_id, (l_custom_tbl(i).PERIOD_START_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                    l_begin_funded_amount := l_begin_funded_amount_new;
                    l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                    l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal;
                else
                    l_remaining_balance_theory := 0;
                end if;

            else

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_custom_tbl(i).PAYMENT_NUMBER > (l_last_installment_billed + 1)');
                if l_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_custom_tbl(i).PERIOD_START_DATE-1));
                    l_begin_funded_amount := LNS_FINANCIALS.getFundedAmount(p_loan_id, (l_custom_tbl(i).PERIOD_START_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_custom_tbl(i).PERIOD_START_DATE);
                    l_begin_funded_amount_new := LNS_FINANCIALS.getFundedAmount(p_loan_id, l_custom_tbl(i).PERIOD_START_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_custom_tbl(i).PERIOD_END_DATE-1));
                    l_end_funded_amount := LNS_FINANCIALS.getFundedAmount(p_loan_id, (l_custom_tbl(i).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');
                        l_detail_int_calc_flag := true;

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := i;
                        else
                            if l_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := i + 1;
                            elsif l_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := i;
                            end if;
                        end if;

                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_sum_periodic_principal = ' || l_sum_periodic_principal);

                        l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                        l_begin_funded_amount := l_begin_funded_amount_new;
                        l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                        l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal - l_sum_periodic_principal;
                    end if;
                else
                    l_remaining_balance_theory := 0;
                end if;

            end if;

        end if;

        if l_loan_details.REAMORTIZE_ON_FUNDING = 'NO' then
            l_increase_amount_instal := -1;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount = ' || l_increased_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount1 = ' || l_increased_amount1);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': LOCK_INT = ' || l_custom_tbl(i).LOCK_INT);

        -- calc interest amount
        if l_custom_tbl(i).LOCK_INT = 'N' or l_loan_details.LOAN_STATUS = 'PAIDOFF' then

            if l_detail_int_calc_flag then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = true');
            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = false');
            end if;

--            if ((P_BASED_ON_TERMS = 'CURRENT' and l_custom_tbl(i).PAYMENT_NUMBER = (l_last_installment_billed + 1)) or
--                l_detail_int_calc_flag = true) then
            if (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating normal interest...');
                LNS_FINANCIALS.CALC_NORM_INTEREST(p_loan_id => p_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_period_begin_date,
                                    p_period_end_date => l_period_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_freq,
                                    p_compound_freq => l_compound_freq,
                                    p_adj_amount => l_sum_periodic_principal,
                                    x_norm_interest => l_norm_interest,
                                    x_norm_int_details => l_norm_int_detail_str);

                l_norm_interest  := round(l_norm_interest, l_precision);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_custom_tbl(i).PAYMENT_NUMBER-1: ' || (l_custom_tbl(i).PAYMENT_NUMBER-1));
                if (l_custom_tbl(i).PAYMENT_NUMBER)-1 >= 0 then

                    -- get additional interest start date
                    open c_get_last_bill_date(p_loan_id, (l_custom_tbl(i).PAYMENT_NUMBER-1));
                    fetch c_get_last_bill_date into l_add_start_date;
                    close c_get_last_bill_date;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_start_date: ' || l_add_start_date);

                    -- get additional interest end date
                    --l_add_end_date := l_period_end_date;

                    if trunc(sysdate) > trunc(l_period_end_date) then
                        l_add_end_date := l_period_end_date;
                    else
                        l_add_end_date := sysdate;
                    end if;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_end_date: ' || l_add_end_date);

                    if (l_custom_tbl(i).PAYMENT_NUMBER-1) > 0 then
                        l_payment := getPayment(p_loan_id, (l_custom_tbl(i).PAYMENT_NUMBER-1)); -- fix for bug 7319358
                        l_prev_grace_end_date := l_payment.PERIOD_BEGIN_DATE + l_loan_details.PENAL_INT_GRACE_DAYS;
                    else
                        l_prev_grace_end_date := l_period_begin_date;
                    end if;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_prev_grace_end_date: ' || l_prev_grace_end_date);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid principal...');
                    -- calculate additional interest on unpaid principal
                    LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => p_loan_id,
                                        p_calc_method => l_calc_method,
                                        p_period_start_date => l_add_start_date,
                                        p_period_end_date => l_add_end_date,
                                        p_interest_rate => l_annualized_rate,
                                        p_day_count_method => l_day_count_method,
                                        p_payment_freq => l_payment_freq,
                                        p_compound_freq => l_compound_freq,
                                        p_penal_int_rate => l_loan_details.PENAL_INT_RATE,
                                        p_prev_grace_end_date => l_prev_grace_end_date,
                                        p_grace_start_date => l_period_begin_date,
                                        p_grace_end_date => (l_period_begin_date + l_loan_details.PENAL_INT_GRACE_DAYS),
                                        p_target => 'UNPAID_PRIN',
                                        x_add_interest => l_add_prin_interest,
                                        x_penal_interest => l_penal_prin_interest,
                                        x_add_int_details => l_add_prin_int_detail_str,
                                        x_penal_int_details => l_penal_prin_int_detail_str);
                    l_add_prin_interest  := round(l_add_prin_interest, l_precision);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid interest...');
                    -- calculate additional interest on unpaid interest
                    LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => p_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_freq,
                                    p_compound_freq => l_compound_freq,
                                    p_penal_int_rate => l_loan_details.PENAL_INT_RATE,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_grace_start_date => l_period_begin_date,
                                    p_grace_end_date => (l_period_begin_date + l_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_INT',
                                    x_add_interest => l_add_int_interest,
                                    x_penal_interest => l_penal_int_interest,
                                    x_add_int_details => l_add_int_int_detail_str,
                                    x_penal_int_details => l_penal_int_int_detail_str);
                    l_add_int_interest  := round(l_add_int_interest, l_precision);

                    if l_penal_prin_int_detail_str is not null and l_penal_int_int_detail_str is not null then
                        l_penal_int_detail_str := l_penal_prin_int_detail_str || '+<br>' || l_penal_int_int_detail_str;
                    else
                        l_penal_int_detail_str := l_penal_prin_int_detail_str || l_penal_int_int_detail_str;
                    end if;
                end if;

            elsif (p_based_on_terms <> 'CURRENT' and l_detail_int_calc_flag = true) then

                if (l_calc_method = 'SIMPLE') then

                    -- recalculate periodic rate for each period if day counting methodolgy varies
                    l_periodic_rate := lns_financials.getPeriodicRate(
                                                p_payment_freq      => l_payment_freq
                                                ,p_period_start_date => l_period_begin_date
                                                ,p_period_end_date   => l_period_end_date
                                                ,p_annualized_rate   => l_annualized_rate
                                                ,p_days_count_method => l_day_count_method
                                                ,p_target            => 'INTEREST');

                elsif (l_calc_method = 'COMPOUND') then

                    l_periodic_rate := lns_financials.getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                    ,p_payment_freq => l_payment_freq
                                    ,p_annualized_rate => l_annualized_rate
                                    ,p_period_start_date => l_period_begin_date
                                    ,p_period_end_date => l_period_end_date
                                    ,p_days_count_method => l_day_count_method
                                    ,p_target => 'INTEREST');

                end if;

                lns_financials.getWeightedBalance(p_loan_id         => p_loan_id
                                                ,p_from_date        => l_period_begin_date
                                                ,p_to_date          => l_period_end_date
                                                ,p_calc_method      => 'TARGET'
                                                ,p_phase            => 'TERM'
                                                ,p_day_count_method => l_day_count_method
                                                ,p_adj_amount       => l_sum_periodic_principal
                                                ,x_wtd_balance      => l_wtd_balance
                                                ,x_begin_balance    => l_balance1
                                                ,x_end_balance      => l_balance2);

                l_norm_interest := lns_financials.calculateInterest(p_amount => l_wtd_balance
                                                                    ,p_periodic_rate => l_periodic_rate
                                                                    ,p_compounding_period => null);
                l_norm_interest := round(l_norm_interest, l_precision);

                l_norm_int_detail_str :=
                    'Period: ' || l_period_begin_date || ' - ' || (l_period_end_date-1) ||
                    ' * Balance: ' || l_wtd_balance ||
                    ' * Rate: ' || l_annualized_rate || '%';
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

            else

                if (l_calc_method = 'SIMPLE') then

                    -- recalculate periodic rate for each period if day counting methodolgy varies
                    l_periodic_rate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_freq
                                            ,p_period_start_date => l_period_begin_date
                                            ,p_period_end_date   => l_period_end_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'INTEREST');

                elsif (l_calc_method = 'COMPOUND') then

                    l_periodic_rate := lns_financials.getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                    ,p_payment_freq => l_payment_freq
                                    ,p_annualized_rate => l_annualized_rate
                                    ,p_period_start_date => l_period_begin_date
                                    ,p_period_end_date => l_period_end_date
                                    ,p_days_count_method => l_day_count_method
                                    ,p_target => 'INTEREST');
                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_rate: ' || l_periodic_rate);
                l_norm_interest := lns_financials.calculateInterest(p_amount => l_remaining_balance_theory
                                                                    ,p_periodic_rate => l_periodic_rate
                                                                    ,p_compounding_period => null);
                l_norm_interest  := round(l_norm_interest, l_precision);

                l_norm_int_detail_str :=
                    'Period: ' || l_period_begin_date || ' - ' || (l_period_end_date-1) ||
                    ' * Balance:' || l_remaining_balance_theory ||
                    ' * Rate: ' || l_annualized_rate || '%';
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

            end if;

            l_penal_interest := round(l_penal_prin_interest + l_penal_int_interest, l_precision);
            l_custom_tbl(i).INTEREST_AMOUNT := l_norm_interest + l_add_prin_interest + l_add_int_interest + l_penal_interest;

        else
            l_norm_interest := round(l_custom_tbl(i).INTEREST_AMOUNT, l_precision);
            l_norm_int_detail_str := 'Interest amount is frozen';
        end if;

        l_custom_tbl(i).INTEREST_AMOUNT := round(l_custom_tbl(i).INTEREST_AMOUNT, l_precision);

        if l_locked_prin > (l_remaining_balance_theory + l_increased_amount1) then
            l_locked_prin := l_remaining_balance_theory + l_increased_amount1;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_norm_interest = ' || l_norm_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_prin_interest = ' || l_add_prin_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_int_interest = ' || l_add_int_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_penal_interest = ' || l_penal_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': INTEREST_AMOUNT = ' || l_custom_tbl(i).INTEREST_AMOUNT);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': LOCK_PRIN = ' || l_custom_tbl(i).LOCK_PRIN);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': P_AMORT_METHOD = ' || P_AMORT_METHOD);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increase_amount_instal = ' || l_increase_amount_instal);

        -- based on amortization method calc prin or payment
        if P_AMORT_METHOD = 'EQUAL_PRINCIPAL' then

            -- calc principal amount
            if i = 1 or l_increase_amount_instal = i or l_prev_increase_amount_instal = i then
                if l_num_unlocked_prin > 0 then
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating periodic_principal...');
                    l_periodic_principal := lns_financials.calculateEPPayment(p_loan_amount   => (l_remaining_balance_theory - l_locked_prin + l_increased_amount1)
                                                                        ,p_num_intervals => l_num_unlocked_prin
                                                                        ,p_ending_balance=> 0
                                                                        ,p_pay_in_arrears=> true);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_principal: ' || l_periodic_principal);
                else
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Number of unlocked principals: ' || l_num_unlocked_prin);
                    l_periodic_principal := 0;
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_principal: ' || l_periodic_principal);
                end if;
            end if;

            if l_custom_tbl(i).LOCK_PRIN = 'N' then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := periodic_principal');
                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_periodic_principal;
                l_num_unlocked_prin := l_num_unlocked_prin - 1;
            end if;

            if (l_remaining_balance_theory + l_increased_amount1) <= l_custom_tbl(i).PRINCIPAL_AMOUNT then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_remaining_balance_theory <= PRINCIPAL_AMOUNT');
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
               -- l_custom_tbl(i).LOCK_PRIN := 'N';
            else
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'remaining_balance_theory > PRINCIPAL_AMOUNT');
                if i = l_custom_tbl.count then
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Its the last row');
                    -- fix for bug 8309391 - let to lock last prin row
                    if l_custom_tbl(i).LOCK_PRIN = 'N' then
                            if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := unbilled_principal');
                                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_unbilled_principal;
                            else
                                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
                            end if;
                    end if;
                end if;
            end if;

            l_custom_tbl(i).PRINCIPAL_AMOUNT := round(l_custom_tbl(i).PRINCIPAL_AMOUNT, l_precision);
            l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).PRINCIPAL_AMOUNT + l_custom_tbl(i).INTEREST_AMOUNT;

        elsif P_AMORT_METHOD = 'EQUAL_PAYMENT' then

            -- calc payment amount
            if (i = 1 or l_annualized_rate <> l_previous_annualized or
               (i > 1 and l_custom_tbl(i-1).LOCK_PRIN = 'Y' and l_custom_tbl(i).LOCK_PRIN = 'N') or
               (l_prev_increase_amount_instal = i or l_increase_amount_instal = i))
            then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating periodic_payment...');

                if (l_calc_method = 'SIMPLE') then

                    l_rate_to_calculate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_freq
                                            ,p_period_start_date => l_period_begin_date
                                            ,p_period_end_date   => l_loan_details.maturity_Date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'PAYMENT');

                elsif (l_calc_method = 'COMPOUND') then

                    l_rate_to_calculate := lns_financials.getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                        ,p_payment_freq => l_payment_freq
                                        ,p_annualized_rate => l_annualized_rate
                                        ,p_period_start_date => l_period_begin_date
                                        ,p_period_end_date => l_loan_details.maturity_Date
                                        ,p_days_count_method => l_day_count_method
                                        ,p_target => 'PAYMENT');

                end if;

                l_amortization_intervals := l_custom_tbl.count + 1 - i;
                l_periodic_payment := lns_financials.calculatePayment(p_loan_amount   => (l_remaining_balance_theory + l_increased_amount1)
                                                                    ,p_periodic_rate => l_rate_to_calculate
                                                                    ,p_num_intervals => l_amortization_intervals
                                                                    ,p_ending_balance=> 0
                                                                    ,p_pay_in_arrears=> true);


                l_periodic_payment := round(l_periodic_payment, l_precision);
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_payment: ' || l_periodic_payment);
            end if;

            if l_custom_tbl(i).LOCK_PRIN = 'N' then

                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CURRENT_TERM_PAYMENT := l_periodic_payment');
                l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_periodic_payment;
                l_custom_tbl(i).PRINCIPAL_AMOUNT := round(l_custom_tbl(i).CURRENT_TERM_PAYMENT - l_custom_tbl(i).INTEREST_AMOUNT, l_precision);

            else

                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CURRENT_TERM_PAYMENT := PRINCIPAL_AMOUNT+INTEREST_AMOUNT');
                l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).PRINCIPAL_AMOUNT + l_custom_tbl(i).INTEREST_AMOUNT;

            end if;

            if (l_remaining_balance_theory + l_increased_amount1) <= l_custom_tbl(i).PRINCIPAL_AMOUNT then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_remaining_balance_theory <= PRINCIPAL_AMOUNT');
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
                l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).PRINCIPAL_AMOUNT + l_custom_tbl(i).INTEREST_AMOUNT;
                -- l_custom_tbl(i).LOCK_PRIN := 'N';
            else
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'remaining_balance_theory > PRINCIPAL_AMOUNT');
                if i = l_custom_tbl.count then
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Its the last row');
		    -- fix for bug 8309391 - let to lock last prin row
                    if l_custom_tbl(i).LOCK_PRIN = 'N' then
                       if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                           LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := unbilled_principal');
                           l_custom_tbl(i).PRINCIPAL_AMOUNT := l_unbilled_principal;
                       else
                           LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                           l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
                       end if;
		    end if;
                    l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).PRINCIPAL_AMOUNT + l_custom_tbl(i).INTEREST_AMOUNT;
                end if;
            end if;

        elsif P_AMORT_METHOD = 'NONE' then

            if (l_remaining_balance_theory + l_increased_amount1) <= l_custom_tbl(i).PRINCIPAL_AMOUNT then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_remaining_balance_theory <= PRINCIPAL_AMOUNT');
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
                -- l_custom_tbl(i).LOCK_PRIN := 'N';
            else
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'remaining_balance_theory > PRINCIPAL_AMOUNT');
                if i = l_custom_tbl.count then
                    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Its the last row');
		    -- fix for bug 8309391 - let to lock last prin row
                    if l_custom_tbl(i).LOCK_PRIN = 'N' then
                       if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                           LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := unbilled_principal');
                           l_custom_tbl(i).PRINCIPAL_AMOUNT := l_unbilled_principal;
                       else
                           LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT := remaining_balance_theory');
                           l_custom_tbl(i).PRINCIPAL_AMOUNT := l_remaining_balance_theory + l_increased_amount1;
                       end if;
		            end if;
                end if;
            end if;

            l_custom_tbl(i).PRINCIPAL_AMOUNT := round(l_custom_tbl(i).PRINCIPAL_AMOUNT, l_precision);
            l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).PRINCIPAL_AMOUNT + l_custom_tbl(i).INTEREST_AMOUNT;

        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': PRINCIPAL_AMOUNT = ' || l_custom_tbl(i).PRINCIPAL_AMOUNT);

        -- calculating fees
        l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
        l_fee_basis_tbl(1).fee_basis_amount := l_remaining_balance_theory + l_unpaid_principal;
        l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
        l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount;
        l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
        l_fee_basis_tbl(3).fee_basis_amount := l_loan_details.requested_amount;
        --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
        --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

        l_fee_amount := 0;
        l_other_amount := 0;
        l_manual_fee_amount := 0;

        if l_custom_tbl(i).PAYMENT_NUMBER = 1 then
            if l_new_orig_fee_structures.count > 0 then
                l_orig_fees_tbl.delete;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling calculateFees for origination fees...');
                lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                            ,p_installment      => l_custom_tbl(i).PAYMENT_NUMBER
                                            ,p_fee_basis_tbl    => l_fee_basis_tbl
                                            ,p_fee_structures   => l_new_orig_fee_structures
                                            ,x_fees_tbl         => l_orig_fees_tbl
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'calculated origination fees ' || l_orig_fees_tbl.count);

                for k in 1..l_orig_fees_tbl.count loop
                    l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_fee_amount = ' || l_fee_amount);
                end loop;
            end if;
        end if;

        -- calculate the memo fees
        l_memo_fees_tbl.delete;
        if l_memo_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for memo fees...');
            lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                        ,p_installment      => l_custom_tbl(i).PAYMENT_NUMBER
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_memo_fee_structures
                                        ,x_fees_tbl         => l_memo_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'calculated memo fees ' || l_memo_fees_tbl.count);

        end if;

        l_fees_tbl.delete;
        if l_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for recurring fees...');
            lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                        ,p_installment      => l_custom_tbl(i).PAYMENT_NUMBER
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_fee_structures
                                        ,x_fees_tbl         => l_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'calculated fees ' || l_fees_tbl.count);

        end if;

        -- calculate the funding fees
        l_funding_fees_tbl.delete;
        if l_funding_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for funding fees...');
            lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                        ,p_installment      => l_custom_tbl(i).PAYMENT_NUMBER
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_funding_fee_structures
                                        ,x_fees_tbl         => l_funding_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees ' || l_fees_tbl.count);
        end if;

        for j in 1..l_fees_tbl.count loop
            l_fee_amount := l_fee_amount + l_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'recurring calculated fees = ' || l_fee_amount);
        end loop;

        for j in 1..l_funding_fees_tbl.count loop
            l_fee_amount := l_fee_amount + l_funding_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding calculated fees = ' || l_fee_amount);
        end loop;

        for j in 1..l_memo_fees_tbl.count loop
            l_other_amount := l_other_amount + l_memo_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other calculated fees = ' || l_other_amount);
        end loop;

        -- get the manual fees
        open c_manual_fees(p_loan_id, l_custom_tbl(i).PAYMENT_NUMBER);
        fetch c_manual_fees into l_manual_fee_amount;
        close c_manual_fees;

        if l_manual_fee_amount is null then
            l_manual_fee_amount := 0;
        end if;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'manual fee amount is '|| l_manual_fee_amount);
        l_fee_amount := l_fee_amount + l_manual_fee_amount;

        l_custom_tbl(i).FEE_AMOUNT := l_fee_amount;
        l_custom_tbl(i).other_amount  := l_other_amount;

        l_custom_tbl(i).CURRENT_TERM_PAYMENT := l_custom_tbl(i).CURRENT_TERM_PAYMENT + l_custom_tbl(i).FEE_AMOUNT + l_custom_tbl(i).other_amount;
        l_custom_tbl(i).UNPAID_PRIN := l_unpaid_principal;
        l_custom_tbl(i).UNPAID_INT := l_unpaid_interest;
        l_custom_tbl(i).INSTALLMENT_BEGIN_BALANCE := l_remaining_balance_theory;
        l_custom_tbl(i).INSTALLMENT_END_BALANCE := l_remaining_balance_theory + l_increased_amount1 - l_custom_tbl(i).PRINCIPAL_AMOUNT;
        l_custom_tbl(i).NORMAL_INT_AMOUNT    := l_norm_interest;
        l_custom_tbl(i).ADD_PRIN_INT_AMOUNT  := l_add_prin_interest;
        l_custom_tbl(i).ADD_INT_INT_AMOUNT   := l_add_int_interest;
        l_custom_tbl(i).PENAL_INT_AMOUNT     := l_penal_interest;
        l_custom_tbl(i).NORMAL_INT_DETAILS   := l_norm_int_detail_str;
        l_custom_tbl(i).ADD_PRIN_INT_DETAILS := l_add_prin_int_detail_str;
        l_custom_tbl(i).ADD_INT_INT_DETAILS  := l_add_int_int_detail_str;
        l_custom_tbl(i).PENAL_INT_DETAILS    := l_penal_int_detail_str;
        l_custom_tbl(i).FUNDED_AMOUNT        := l_end_funded_amount;
        l_custom_tbl(i).DISBURSEMENT_AMOUNT  := l_increased_amount;

        if l_unbilled_principal > 0 then
            l_unbilled_principal := l_unbilled_principal - l_custom_tbl(i).PRINCIPAL_AMOUNT;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT ' || l_custom_tbl(i).PAYMENT_NUMBER);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_AMOUNT: ' || l_custom_tbl(i).PRINCIPAL_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INTEREST_AMOUNT: ' || l_custom_tbl(i).INTEREST_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FEE_AMOUNT: ' || l_custom_tbl(i).FEE_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CURRENT_TERM_PAYMENT: ' || l_custom_tbl(i).CURRENT_TERM_PAYMENT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT_BEGIN_BALANCE: ' || l_custom_tbl(i).INSTALLMENT_BEGIN_BALANCE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT_END_BALANCE: ' || l_custom_tbl(i).INSTALLMENT_END_BALANCE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'remaining_balance_theory: ' || l_remaining_balance_theory);
--        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'remaining_balance_theory1: ' || l_remaining_balance_theory1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'unbilled_principal: ' || l_unbilled_principal);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_PRIN: ' || l_custom_tbl(i).UNPAID_PRIN);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_INT: ' || l_custom_tbl(i).UNPAID_INT);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_AMOUNT = ' || l_custom_tbl(i).NORMAL_INT_AMOUNT );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_AMOUNT = ' || l_custom_tbl(i).ADD_PRIN_INT_AMOUNT );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_AMOUNT = ' || l_custom_tbl(i).ADD_INT_INT_AMOUNT );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_AMOUNT = ' || l_custom_tbl(i).PENAL_INT_AMOUNT );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FUNDED_AMOUNT = ' || l_custom_tbl(i).FUNDED_AMOUNT );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_DETAILS = ' || l_custom_tbl(i).NORMAL_INT_DETAILS );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_DETAILS = ' || l_custom_tbl(i).ADD_PRIN_INT_DETAILS );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_DETAILS_AMOUNT = ' || l_custom_tbl(i).ADD_INT_INT_DETAILS );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_DETAILS = ' || l_custom_tbl(i).PENAL_INT_DETAILS );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');

        l_remaining_balance_theory := l_custom_tbl(i).INSTALLMENT_END_BALANCE;
        l_sum_periodic_principal := l_sum_periodic_principal + l_custom_tbl(i).PRINCIPAL_AMOUNT;

        l_previous_annualized := l_annualized_rate;
        l_unpaid_principal := 0;
        l_unpaid_interest := 0;
        l_orig_fees_tbl.delete;
        l_memo_fees_tbl.delete;
        l_fees_tbl.delete;
        l_funding_fees_tbl.delete;

    end loop;

    -- fix for bug 8309391 - give warning is amortization schedule does not bring loan balance to 0
    if l_custom_tbl(l_custom_tbl.count).INSTALLMENT_END_BALANCE > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_LOAN_BAL_GREATER_ZERO');
        FND_MSG_PUB.ADD_DETAIL(p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Output Schedule:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PN   DD        RATE  BB      UP      UI      PAY     PRIN    LP  INT=N+P+I+PL     LI  EB     ACT');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '---  --------  ----  ------  ------  ------  ------  ------  --  --------------  -- ------  ---');
    for i in 1..l_custom_tbl.count loop
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                   l_custom_tbl(i).PAYMENT_NUMBER || '  ' ||
                   l_custom_tbl(i).DUE_DATE || '  ' ||
                   l_custom_tbl(i).INTEREST_RATE || '  ' ||
                   l_custom_tbl(i).INSTALLMENT_BEGIN_BALANCE || '  ' ||
                   l_custom_tbl(i).UNPAID_PRIN || '  ' ||
                   l_custom_tbl(i).UNPAID_INT || '  ' ||
                   l_custom_tbl(i).CURRENT_TERM_PAYMENT || '  ' ||
                   l_custom_tbl(i).PRINCIPAL_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_PRIN || '  ' ||
                   l_custom_tbl(i).INTEREST_AMOUNT || '=' || l_custom_tbl(i).NORMAL_INT_AMOUNT || '+' || l_custom_tbl(i).ADD_PRIN_INT_AMOUNT || '+' || l_custom_tbl(i).ADD_INT_INT_AMOUNT || '+' || l_custom_tbl(i).PENAL_INT_AMOUNT || '  ' ||
                   l_custom_tbl(i).LOCK_INT || '  ' ||
                   l_custom_tbl(i).INSTALLMENT_END_BALANCE || '  ' ||
                   l_custom_tbl(i).ACTION);
    end loop;

    P_CUSTOM_TBL := l_CUSTOM_TBL;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO recalcCustomSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO recalcCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO recalcCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



-- This procedure saves custom schedule into db
procedure saveCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'saveCustomSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_CUSTOM_TBL                    LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_custom_rec                    LNS_CUSTOM_PUB.custom_sched_type;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
    l_term_rec                      LNS_TERMS_PUB.loan_term_rec_type;

    l_custom_sched_id               number;
    l_object_version                number;
    l_term_id                       number;
    l_num_installments              number;
    i                               number;
    l_last_billed_due_date          date;
    l_first_payment_date            date;
    l_agreement_reason              varchar2(500);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR last_billed_due_date_cur(P_LOAN_ID NUMBER) IS
        SELECT trunc(max(DUE_DATE)),
            max(term.first_payment_date)
        FROM lns_amortization_scheds am,
            lns_loan_headers_all loan,
            lns_terms term
        WHERE loan.loan_id = P_LOAN_ID
            AND loan.loan_id = term.loan_id
            AND loan.loan_id = am.loan_id(+)
            AND (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
            AND am.REAMORTIZATION_AMOUNT is null
            AND am.PARENT_AMORTIZATION_ID is null
            AND nvl(am.phase, 'TERM') = 'TERM';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT saveCustomSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_AMORT_METHOD: ' || P_AMORT_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_BASED_ON_TERMS: ' || P_BASED_ON_TERMS);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BASED_ON_TERMS is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'BASED_ON_TERMS');
        FND_MESSAGE.SET_TOKEN('VALUE', P_BASED_ON_TERMS);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_AMORT_METHOD is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'AMORT_METHOD');
        FND_MESSAGE.SET_TOKEN('VALUE', P_AMORT_METHOD);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_CUSTOM_TBL := P_CUSTOM_TBL;

    LNS_CUSTOM_PUB.recalcCustomSchedule(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT		        => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID               => P_LOAN_ID,
        P_AMORT_METHOD          => P_AMORT_METHOD,
        P_BASED_ON_TERMS        => P_BASED_ON_TERMS,
        P_CUSTOM_TBL            => l_custom_tbl,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    IF l_return_status <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => P_BASED_ON_TERMS);

    -- invalidate all existent rows in LNS_CUSTOM_PAYMNT_SCHEDS greater than l_loan_details.LAST_INSTALLMENT_BILLED
    update LNS_CUSTOM_PAYMNT_SCHEDS
    set PAYMENT_NUMBER = -1
    where loan_id = p_loan_id
    and PAYMENT_NUMBER > l_loan_details.LAST_INSTALLMENT_BILLED;

    -- insert and update valid rows
    for i in 1..l_custom_tbl.count loop

        l_custom_rec := l_custom_tbl(i);

        if l_custom_tbl(i).ACTION is null or l_custom_tbl(i).ACTION = 'U' then

            -- getting info from lns_loan_headers_all
            select object_version_number
            into l_custom_rec.OBJECT_VERSION_NUMBER
            from LNS_CUSTOM_PAYMNT_SCHEDS
            where loan_id = p_loan_id and
            CUSTOM_SCHEDULE_ID = l_custom_tbl(i).CUSTOM_SCHEDULE_ID;


            -- call api to update rows one-by-one for compliance reasons
            lns_custom_pub.updateCustomSched(P_CUSTOM_REC    => l_custom_rec
                                            ,x_return_status => l_return_status
                                            ,x_msg_count     => l_msg_Count
                                            ,x_msg_data      => l_msg_Data);

            IF l_return_status <> 'S' THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        elsif l_custom_tbl(i).ACTION = 'I' then

            -- call api to update rows one-by-one for compliance reasons
            lns_custom_pub.createCustomSched(P_CUSTOM_REC      => l_custom_rec
                                            ,x_return_status   => l_return_status
                                            ,x_custom_sched_id => l_custom_sched_id
                                            ,x_msg_count       => l_msg_Count
                                            ,x_msg_data        => l_msg_Data);

            IF l_return_status <> 'S' THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_custom_tbl(i).CUSTOM_SCHEDULE_ID := l_custom_sched_id;

        end if;
/*  commented out during fix for bug 9142180
        -- fix for bug 7143022: set next payment due date to due date of the first to be billed custom installment and set BILLED_FLAG to 'N'
        if P_BASED_ON_TERMS = 'CURRENT' and i = 1 then
            l_term_rec.NEXT_PAYMENT_DUE_DATE := l_custom_tbl(i).DUE_DATE;
            l_loan_header_rec.BILLED_FLAG := 'N';
        end if;
*/
    end loop;

    -- fix for bug 9142180: set NEXT_PAYMENT_DUE_DATE to last billed due date and set BILLED_FLAG to 'Y'
    if P_BASED_ON_TERMS = 'CURRENT' then

        OPEN last_billed_due_date_cur(p_loan_id);
        FETCH last_billed_due_date_cur INTO l_last_billed_due_date, l_first_payment_date;
        CLOSE last_billed_due_date_cur;

        if l_last_billed_due_date is not null then
            l_term_rec.NEXT_PAYMENT_DUE_DATE := l_last_billed_due_date;
            l_loan_header_rec.BILLED_FLAG := 'Y';
        else
            l_term_rec.NEXT_PAYMENT_DUE_DATE := l_first_payment_date;
            l_loan_header_rec.BILLED_FLAG := FND_API.G_MISS_CHAR;
        end if;

    end if;

    -- deleting all invalid rows
    delete from LNS_CUSTOM_PAYMNT_SCHEDS where loan_id = p_loan_id and PAYMENT_NUMBER = -1;

    -- update all rows with action null
    for i in 1..l_custom_tbl.count loop
        l_custom_tbl(i).ACTION := null;
    end loop;

    -- getting info from lns_loan_headers_all
    select object_version_number
    into l_object_version
    from lns_loan_headers_all
    where loan_id = p_loan_id;

    -- update lns_loan_headers_all only if loan is not custom yet
    if l_loan_details.CUSTOM_SCHEDULE = 'N' or l_loan_header_rec.BILLED_FLAG is not null then
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_loan_headers_all w following values:');
        l_loan_header_rec.loan_id := P_LOAN_ID;
        l_loan_header_rec.CUSTOM_PAYMENTS_FLAG := 'Y';

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CUSTOM_PAYMENTS_FLAG = ' || l_loan_header_rec.CUSTOM_PAYMENTS_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'BILLED_FLAG = ' || l_loan_header_rec.BILLED_FLAG);

        lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_TRUE
                                        ,p_loan_header_rec       => l_loan_header_rec
                                        ,P_OBJECT_VERSION_NUMBER => l_object_version
                                        ,X_RETURN_STATUS         => l_return_status
                                        ,X_MSG_COUNT             => l_msg_count
                                        ,X_MSG_DATA              => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully updated lns_loan_headers_all');
        ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    -- getting terms version for future update
    select term_id, object_version_number into l_term_id, l_object_version
    from lns_terms
    where loan_id = p_loan_id;

    -- Updating terms
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_terms w following values:');

    l_term_rec.TERM_ID := l_term_id;
    l_term_rec.LOAN_ID := p_loan_id;
    l_term_rec.PAYMENT_CALC_METHOD := 'CUSTOM';
    l_term_rec.CUSTOM_CALC_METHOD := P_AMORT_METHOD;

    if l_loan_details.loan_status <> 'INCOMPLETE' and l_loan_details.CUSTOM_SCHEDULE = 'N' then
        l_term_rec.ORIG_PAY_CALC_METHOD := l_loan_details.PAYMENT_CALC_METHOD;
    elsif l_loan_details.loan_status = 'INCOMPLETE' then
        l_term_rec.ORIG_PAY_CALC_METHOD := FND_API.G_MISS_CHAR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_CALC_METHOD = ' || l_term_rec.PAYMENT_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CUSTOM_CALC_METHOD = ' || l_term_rec.CUSTOM_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ORIG_PAY_CALC_METHOD = ' || l_term_rec.ORIG_PAY_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NEXT_PAYMENT_DUE_DATE = ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);

    LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_object_version,
                              p_init_msg_list => FND_API.G_FALSE,
                              p_loan_term_rec => l_term_rec,
                              X_RETURN_STATUS => l_return_status,
                              X_MSG_COUNT => l_msg_count,
                              X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully update LNS_TERMS');
    ELSE
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_TERMS_PUB.update_term returned error: ' || substr(l_msg_data,1,225));
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- getting number of installments and synching rate schedule
    if l_custom_tbl.count > 0 then
        l_num_installments := l_custom_tbl(l_custom_tbl.count).PAYMENT_NUMBER;
    else
        l_num_installments := l_loan_details.LAST_INSTALLMENT_BILLED;
        if l_num_installments = 0 then
            l_num_installments := 1;
        end if;
    end if;

    synchRateSchedule(l_term_id, l_num_installments);

    P_CUSTOM_TBL := l_CUSTOM_TBL;

    if P_BASED_ON_TERMS = 'CURRENT' then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CUST_SCHED_AGR_REASON');
        FND_MSG_PUB.Add;
        l_agreement_reason := FND_MSG_PUB.Get(p_encoded => 'F');
        FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

        LNS_REP_UTILS.STORE_LOAN_AGREEMENT_CP(p_loan_id, l_agreement_reason);
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO saveCustomSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO saveCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO saveCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



-- This procedure switches back from custom schedule to standard schedule in one shot
-- Conditions: loan status is INCOMPLETE and loan has been already customized
procedure uncustomizeSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_ST_AMORT_METHOD   IN              VARCHAR2,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'uncustomizeSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
    l_term_rec                      LNS_TERMS_PUB.loan_term_rec_type;

    l_object_version                number;
    l_term_id                       number;
    l_BASED_ON_TERMS                varchar2(30);
    l_num_installments              number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT uncustomizeSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_ST_AMORT_METHOD: ' || P_ST_AMORT_METHOD);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_BASED_ON_TERMS := 'ORIGINATION';
    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => l_based_on_terms);

    -- allow to save initial custom schedule only if this loan is in INCOMPLETE status and is not customized yet
--    if l_loan_details.loan_status = 'INCOMPLETE' and l_loan_details.CUSTOM_SCHEDULE = 'Y' then
    if l_loan_details.loan_status = 'INCOMPLETE' then

        delete from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = p_loan_id;
/*
        -- getting info from lns_loan_headers_all
        select object_version_number
        into l_object_version
        from lns_loan_headers_all
        where loan_id = p_loan_id;

        -- update lns_loan_headers_all only if loan is not custom yet
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_loan_headers_all set custom = N');
        l_loan_header_rec.loan_id := P_LOAN_ID;
        l_loan_header_rec.CUSTOM_PAYMENTS_FLAG := 'N';

        lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_TRUE
                                        ,p_loan_header_rec       => l_loan_header_rec
                                        ,P_OBJECT_VERSION_NUMBER => l_object_version
                                        ,X_RETURN_STATUS         => l_return_status
                                        ,X_MSG_COUNT             => l_msg_count
                                        ,X_MSG_DATA              => l_msg_data);

        LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully updated lns_loan_headers_all');
        ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        -- getting terms version for future update
        select term_id, object_version_number into l_term_id, l_object_version
        from lns_terms
        where loan_id = p_loan_id;

        -- Updating terms
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_terms w following values:');

        l_term_rec.TERM_ID := l_term_id;
        l_term_rec.LOAN_ID := p_loan_id;
        l_term_rec.PAYMENT_CALC_METHOD := P_ST_AMORT_METHOD;
        l_term_rec.CUSTOM_CALC_METHOD := FND_API.G_MISS_CHAR;
        l_term_rec.ORIG_PAY_CALC_METHOD := FND_API.G_MISS_CHAR;

        LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_object_version,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_loan_term_rec => l_term_rec,
                                X_RETURN_STATUS => l_return_status,
                                X_MSG_COUNT => l_msg_count,
                                X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully update LNS_TERMS');
        ELSE
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_TERMS_PUB.update_term returned error: ' || substr(l_msg_data,1,225));
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- synching rate schedule
        l_num_installments := LNS_FIN_UTILS.getNumberInstallments(p_loan_id);
        synchRateSchedule(l_term_id, l_num_installments);
*/
    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Nothing to update');
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO uncustomizeSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO uncustomizeSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO uncustomizeSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



-- This procedure switches from standard schedule to custom schedule in one shot
-- Conditions: loan status is INCOMPLETE and loan has not been customized yet
procedure customizeSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'customizeSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_custom_tbl                    LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_AMORT_METHOD                  varchar2(30);
    l_BASED_ON_TERMS                varchar2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT customizeSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_BASED_ON_TERMS := 'ORIGINATION';
    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => l_based_on_terms);

    -- allow to save initial custom schedule only if this loan is in INCOMPLETE status and is not customized yet
    if l_loan_details.loan_status = 'INCOMPLETE' and l_loan_details.CUSTOM_SCHEDULE = 'N' then

        -- load initial schedule
        LNS_CUSTOM_PUB.loadCustomSchedule(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => P_LOAN_ID,
            P_BASED_ON_TERMS        => l_BASED_ON_TERMS,
            X_AMORT_METHOD          => l_AMORT_METHOD,
            X_CUSTOM_TBL            => l_custom_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- immediatly save it
        LNS_CUSTOM_PUB.saveCustomSchedule(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => P_LOAN_ID,
            P_BASED_ON_TERMS        => l_BASED_ON_TERMS,
            P_AMORT_METHOD          => l_AMORT_METHOD,
            P_CUSTOM_TBL            => l_custom_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO customizeSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO customizeSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO customizeSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



/*
This funciton will ensure the rows in the custom tbl are ordered by due date.
Will validate that due dates are unique
Return 1 - success; 0 - failed
*/
function shiftRowsByDate(P_OLD_DUE_DATE IN  DATE,
                          P_NEW_DUE_DATE IN  DATE,
                          p_custom_tbl   in out nocopy LNS_CUSTOM_PUB.custom_tbl) return NUMBER
is
    l_custom_tbl        LNS_CUSTOM_PUB.custom_tbl;
    i                   number;
    l_found             boolean;
    l_shift_from_row    number;
    l_month_diff        number;
    l_day_diff          number;
    l_old_date          date;

begin
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'shiftRowsByDate +');

    if P_OLD_DUE_DATE is null then
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_OLD_DUE_DATE is null. Exiting');
        return 0;
    end if;

    if P_OLD_DUE_DATE is null or P_OLD_DUE_DATE = P_NEW_DUE_DATE then
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_OLD_DUE_DATE = P_NEW_DUE_DATE. Exiting');
        return 1;
    end if;

    l_custom_tbl := p_custom_tbl;
    l_found := false;

    -- find row from which we will shift schedule
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Looking for start shift row...');
    for i in 1..l_custom_tbl.count loop
        if l_custom_tbl(i).DUE_DATE = P_NEW_DUE_DATE then
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Found row ' || i);
            l_shift_from_row := i;
            l_found := true;

            l_month_diff := months_between(P_NEW_DUE_DATE, P_OLD_DUE_DATE);
            if sign(l_month_diff) = -1 then
                l_month_diff := ceil(l_month_diff);
            elsif sign(l_month_diff) = 1 then
                l_month_diff := floor(l_month_diff);
            end if;
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_month_diff: ' || l_month_diff);

            l_day_diff := P_NEW_DUE_DATE - add_months(P_OLD_DUE_DATE, l_month_diff);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_day_diff: ' || l_day_diff);
            exit;
        end if;
    end loop;

    if l_found = false then
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'No start shift row found. Exiting');
        return 1;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Shifting dates...');
    for i in l_shift_from_row..l_custom_tbl.count loop

        if i = l_shift_from_row then
            l_old_date := P_OLD_DUE_DATE;
        else
            l_old_date := l_custom_tbl(i).DUE_DATE;
            l_custom_tbl(i).DUE_DATE := add_months(l_old_date, l_month_diff) + l_day_diff;
        end if;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_old_date || ' -> ' || l_custom_tbl(i).DUE_DATE);

    end loop;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done shifting.');

    p_custom_tbl := l_custom_tbl;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'shiftRowsByDate -');

    return 1;
end;




-- This procedure recalculates custom schedule with shifting all subsequent due dates on a single due date change
procedure shiftCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_OLD_DUE_DATE      IN              DATE,
        P_NEW_DUE_DATE      IN              DATE,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'shiftCustomSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_custom_tbl                    LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_return                        number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT shiftCustomSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_OLD_DUE_DATE: ' || P_OLD_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_NEW_DUE_DATE: ' || P_NEW_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_AMORT_METHOD: ' || P_AMORT_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_BASED_ON_TERMS: ' || P_BASED_ON_TERMS);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BASED_ON_TERMS is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'BASED_ON_TERMS');
        FND_MESSAGE.SET_TOKEN('VALUE', P_BASED_ON_TERMS);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_AMORT_METHOD is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'AMORT_METHOD');
        FND_MESSAGE.SET_TOKEN('VALUE', P_AMORT_METHOD);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_NEW_DUE_DATE is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'NEW_DUE_DATE');
        FND_MESSAGE.SET_TOKEN('VALUE', P_NEW_DUE_DATE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_CUSTOM_TBL := P_CUSTOM_TBL;

    filterCustSchedule(l_custom_tbl);
    if l_custom_tbl.count = 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Custom amortization is empty.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CUST_AMORT_EMPTY');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_return := shiftRowsByDate(P_OLD_DUE_DATE      => P_OLD_DUE_DATE,
                                P_NEW_DUE_DATE      => P_NEW_DUE_DATE,
                                P_CUSTOM_TBL        => l_CUSTOM_TBL);

    if l_return = 0 then
        return;
    end if;

    LNS_CUSTOM_PUB.recalcCustomSchedule(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT		        => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID               => P_LOAN_ID,
        P_AMORT_METHOD          => P_AMORT_METHOD,
        P_BASED_ON_TERMS        => P_BASED_ON_TERMS,
        P_CUSTOM_TBL            => l_custom_tbl,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    IF l_return_status <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    P_CUSTOM_TBL := l_CUSTOM_TBL;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO shiftCustomSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO shiftCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO shiftCustomSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;


procedure reBuildCustomdSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'reBuildCustomdSchedule';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_loan_header_rec          LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
    l_term_rec                       LNS_TERMS_PUB.loan_term_rec_type;

    l_object_version                number;
    l_term_id                       number;
    l_BASED_ON_TERMS                varchar2(30);
    l_num_installments              number;
    l_maturity_date		DATE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT reBuildCustomdSchedule;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', P_LOAN_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_BASED_ON_TERMS := 'ORIGINATION';
    l_loan_details  := getLoanDetails(p_loan_Id            => p_loan_id
                                      ,p_based_on_terms    => l_based_on_terms);

     l_maturity_date := l_loan_details.MATURITY_DATE;

    -- allow to reBuild custom schedule only if this loan is in INCOMPLETE status
    --if l_loan_details.loan_status = 'INCOMPLETE' then
    if l_loan_details.loan_status = 'INCOMPLETE' and l_loan_details.CUSTOM_SCHEDULE = 'Y' then

        delete from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = p_loan_id
	and due_date > l_maturity_date;

	LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Cust Rows might be deleted.');

    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Nothing to update');
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO reBuildCustomdSchedule;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO reBuildCustomdSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO reBuildCustomdSchedule;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;


-- This procedure builds custom payment schedule and returns LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL table
function buildCustomPaySchedule(P_LOAN_ID IN NUMBER) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'buildCustomPaySchedule';
    l_payment_schedule              LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_due_date                      date;
    l_payment_number                number;
    i                               number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- cursor to get due_dates of already built installments
    cursor c_built_payments(p_loan_id NUMBER) IS
    select PAYMENT_NUMBER, DUE_DATE
    from lns_amortization_scheds
    where loan_id = p_loan_id
      and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
      and parent_amortization_id is null
      and REAMORTIZATION_AMOUNT is null
      and nvl(phase, 'TERM') = 'TERM'
    order by PAYMENT_NUMBER;

    -- cursor to load custom schedule
    cursor c_load_sched(p_loan_id NUMBER, p_min_payment NUMBER) IS
    select PAYMENT_NUMBER, DUE_DATE
    from LNS_CUSTOM_PAYMNT_SCHEDS
    where loan_id = p_loan_id
      and PAYMENT_NUMBER >= p_min_payment
    order by PAYMENT_NUMBER;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_LOAN_ID: ' || P_LOAN_ID);

    l_loan_details  := getLoanDetails(p_loan_id => p_loan_id
                                      ,p_based_on_terms => 'CURRENT');

    if l_loan_details.CUSTOM_SCHEDULE = 'N' then
        return l_payment_schedule;
    end if;

    i := 1;
    if l_loan_details.LAST_INSTALLMENT_BILLED > 0 then

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Loading dates from lns_amortization_scheds:');
        OPEN c_built_payments(p_loan_id);
        LOOP

            FETCH c_built_payments INTO l_payment_number, l_due_date;
            exit when c_built_payments%NOTFOUND;

            if i = 1 then
                l_payment_schedule(i).PERIOD_BEGIN_DATE := l_loan_details.LOAN_START_DATE;
            else
                l_payment_schedule(i).PERIOD_BEGIN_DATE := l_payment_schedule(i-1).PERIOD_END_DATE;
            end if;

            l_payment_schedule(i).PERIOD_DUE_DATE := l_due_date;
            l_payment_schedule(i).PERIOD_END_DATE := l_due_date;

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Payment ' || l_payment_number);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_BEGIN_DATE: ' || l_payment_schedule(i).PERIOD_BEGIN_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_DUE_DATE: ' || l_payment_schedule(i).PERIOD_DUE_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_END_DATE: ' || l_payment_schedule(i).PERIOD_END_DATE);
            i := i + 1;

        END LOOP;
        CLOSE c_built_payments;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Loading dates from LNS_CUSTOM_PAYMNT_SCHEDS:');
    OPEN c_load_sched(p_loan_id, i);
    LOOP

        FETCH c_load_sched INTO l_payment_number, l_due_date;
        exit when c_load_sched%NOTFOUND;

            if i = 1 then
                l_payment_schedule(i).PERIOD_BEGIN_DATE := l_loan_details.LOAN_START_DATE;
            else
                l_payment_schedule(i).PERIOD_BEGIN_DATE := l_payment_schedule(i-1).PERIOD_END_DATE;
            end if;

            l_payment_schedule(i).PERIOD_DUE_DATE := l_due_date;
            l_payment_schedule(i).PERIOD_END_DATE := l_due_date;

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Payment ' || l_payment_number);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_BEGIN_DATE: ' || l_payment_schedule(i).PERIOD_BEGIN_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_DUE_DATE: ' || l_payment_schedule(i).PERIOD_DUE_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_END_DATE: ' || l_payment_schedule(i).PERIOD_END_DATE);
            i := i + 1;

    END LOOP;
    CLOSE c_load_sched;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

    return l_payment_schedule;
END;


-- added for bug 7716548
-- This procedure adds installment to custom schedule only if it does not already exist
procedure addMissingInstallment(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_INSTALLMENT_REC   IN              LNS_CUSTOM_PUB.custom_sched_type,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'addMissingInstallment';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_CUSTOM_PUB.LOAN_DETAILS_REC;
    l_custom_sched_id               NUMBER;
    l_INSTALLMENT_REC               LNS_CUSTOM_PUB.custom_sched_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

   -- check is such payment already exist
   cursor c_exist_installment(p_loan_id NUMBER, p_payment_number NUMBER) IS
   select custom_schedule_id
     from lns_custom_paymnt_scheds
    where loan_id = p_loan_id
      and payment_number = p_payment_number;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT addMissingInstallment;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    l_INSTALLMENT_REC := P_INSTALLMENT_REC;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.LOAN_ID: ' || l_INSTALLMENT_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.PAYMENT_NUMBER: ' || l_INSTALLMENT_REC.PAYMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.DUE_DATE: ' || l_INSTALLMENT_REC.DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.PRINCIPAL_AMOUNT: ' || l_INSTALLMENT_REC.PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.INTEREST_AMOUNT: ' || l_INSTALLMENT_REC.INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.FEE_AMOUNT: ' || l_INSTALLMENT_REC.FEE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.OTHER_AMOUNT: ' || l_INSTALLMENT_REC.OTHER_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.LOCK_PRIN: ' || l_INSTALLMENT_REC.LOCK_PRIN);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_INSTALLMENT_REC.LOCK_INT: ' || l_INSTALLMENT_REC.LOCK_INT);

    if l_INSTALLMENT_REC.LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', l_INSTALLMENT_REC.LOAN_ID);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_INSTALLMENT_REC.PAYMENT_NUMBER is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'PAYMENT_NUMBER');
        FND_MESSAGE.SET_TOKEN('VALUE', l_INSTALLMENT_REC.PAYMENT_NUMBER);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_INSTALLMENT_REC.DUE_DATE is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'DUE_DATE');
        FND_MESSAGE.SET_TOKEN('VALUE', l_INSTALLMENT_REC.DUE_DATE);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    open c_exist_installment(l_INSTALLMENT_REC.LOAN_ID, l_INSTALLMENT_REC.PAYMENT_NUMBER);
    fetch c_exist_installment into l_custom_sched_id;
    close c_exist_installment;

    if l_custom_sched_id is not null then
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Payment ' || l_INSTALLMENT_REC.PAYMENT_NUMBER || ' already exist in the custom schedule (l_custom_sched_id = ' || l_custom_sched_id || '). Returning.');
        return;
    end if;

    l_loan_details  := getLoanDetails(p_loan_id => l_INSTALLMENT_REC.LOAN_ID
                                      ,p_based_on_terms => 'CURRENT');

    if l_loan_details.CUSTOM_SCHEDULE = 'N' then
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Cannot add custom installment b/c schedule is not customized. Returning.');
        return;
    end if;

    if l_INSTALLMENT_REC.PRINCIPAL_AMOUNT is null then
        l_INSTALLMENT_REC.PRINCIPAL_AMOUNT := 0;
    end if;

    if l_INSTALLMENT_REC.INTEREST_AMOUNT is null then
        l_INSTALLMENT_REC.INTEREST_AMOUNT := 0;
    end if;

    if l_INSTALLMENT_REC.FEE_AMOUNT is null then
        l_INSTALLMENT_REC.FEE_AMOUNT := 0;
    end if;

    if l_INSTALLMENT_REC.OTHER_AMOUNT is null then
        l_INSTALLMENT_REC.OTHER_AMOUNT := 0;
    end if;

    if l_INSTALLMENT_REC.LOCK_PRIN is null then
        l_INSTALLMENT_REC.LOCK_PRIN := 'Y';
    end if;

    if l_INSTALLMENT_REC.LOCK_INT is null then
        l_INSTALLMENT_REC.LOCK_INT := 'Y';
    end if;

    -- call api to insert new row
    lns_custom_pub.createCustomSched(P_CUSTOM_REC      => l_INSTALLMENT_REC
                                    ,x_return_status   => l_return_status
                                    ,x_custom_sched_id => l_custom_sched_id
                                    ,x_msg_count       => l_msg_Count
                                    ,x_msg_data        => l_msg_Data);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Failed to insert custom schedule row');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Successfully added installment ' || l_INSTALLMENT_REC.PAYMENT_NUMBER || ' to custom schedule');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO addMissingInstallment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO addMissingInstallment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO addMissingInstallment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;


END LNS_CUSTOM_PUB;


/
