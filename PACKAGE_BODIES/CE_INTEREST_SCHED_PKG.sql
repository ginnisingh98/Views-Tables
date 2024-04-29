--------------------------------------------------------
--  DDL for Package Body CE_INTEREST_SCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_INTEREST_SCHED_PKG" as
/* $Header: ceintscb.pls 120.1 2005/07/29 20:42:04 lkwan ship $ */

  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--  l_DEBUG varchar2(1) := 'Y';

--
-- cursor used when update/delete schedule or remove/add accounts to schedule
--
  CURSOR SCHED_XTR_ACCTS(P_INTEREST_SCHEDULE_ID NUMBER,
		         P_BANK_ACCOUNT_ID 	NUMBER)  IS
	SELECT BA.BANK_ACCOUNT_ID
	FROM CE_BANK_ACCT_USES_ALL  	BAU
	  , CE_BANK_ACCOUNTS		BA
	WHERE
	  BA.BANK_ACCOUNT_ID 	    = BAU.BANK_ACCOUNT_ID
	AND BAU.XTR_USE_ENABLE_FLAG = 'Y'
	AND BA.INTEREST_SCHEDULE_ID = P_INTEREST_SCHEDULE_ID
	AND BA.BANK_ACCOUNT_ID      = NVL(P_BANK_ACCOUNT_ID, BA.BANK_ACCOUNT_ID);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      xtr_schedule_update
|                                                                       |
|  CALLED BY                                                            |
|      update_schedule, remove_schedule_account, assign_schedule_account|
|                                                                       |
|  DESCRIPTION                                                          |
|      call xtr API when schedule related information has changed
|      Following API needs to be called when
|	-added a Treasury Bank account to an interest schedule
| 	-removed a treasury Bank account from an interest schedule.
|	-updated interest schedule information that is attached to a
| 		treasury bank account
 --------------------------------------------------------------------- */
PROCEDURE  xtr_schedule_update(p_ce_bank_account_id 	IN 	number,
			   	p_interest_rounding 	IN 	varchar2,
				p_interest_includes 	IN 	varchar2,
				p_basis 		IN 	varchar2,
				p_day_count_basis 	IN 	varchar2,
				x_return_status 	   OUT NOCOPY varchar2,
				x_msg_count	 	   OUT NOCOPY number,
				x_msg_data	 	   OUT NOCOPY varchar2
			) IS
  BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.xtr_schedule_update');
  END IF;

  IF (p_ce_bank_account_id is not null ) THEN

    XTR_REPLICATE_BANK_ACCOUNTS_P.REPLICATE_INTEREST_SCHEDULES
		( p_ce_bank_account_id   	=> p_ce_bank_account_id,
		  p_interest_rounding 	 	=> p_interest_rounding ,
		  p_interest_includes 		=>  p_interest_includes,
                  p_interest_calculation_basis 	=>  p_basis,
                  p_day_count_basis 		=>  p_day_count_basis,
                  x_return_status    		=>  x_return_status,
                  x_msg_count     		=>  x_msg_count,
                  x_msg_data     		=>  x_msg_data);

  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_INTEREST_SCHED_PKG.xtr_schedule_update p_ce_bank_account_id missing');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_BANK_ACCOUNT_ID_MISSING');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.xtr_schedule_update');
    fnd_msg_pub.add;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.xtr_schedule_update');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.xtr_schedule_update');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.xtr_schedule_update');
    fnd_msg_pub.add;
END xtr_schedule_update;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      remove_schedule_account	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl (ScheduleBankAcctPG/CO)                           |
|      delete_schedule                                                  |
|                                                                       |
|  DESCRIPTION                                                          |
|      remove bank accounts that has been assign to schedule		|
|        CE_BANK_ACCOUNTS			                        |
 --------------------------------------------------------------------- */
PROCEDURE  remove_schedule_account(p_interest_schedule_id IN	number,
				   p_bank_account_id 	  IN	number,
			      	   x_return_status        IN OUT NOCOPY VARCHAR2,
    			      	   x_msg_count               OUT NOCOPY NUMBER,
			      	   x_msg_data                OUT NOCOPY VARCHAR2
		)  IS

 x_bank_account_id  	NUMBER;
 BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.remove_schedule_account');
  END IF;
  -- initialize API return status to success.
  x_return_status := fnd_api.g_ret_sts_success;

  IF (p_interest_schedule_id is not null and p_bank_account_id is not null)  THEN
    UPDATE CE_BANK_ACCOUNTS
    SET INTEREST_SCHEDULE_ID = NULL
    WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id
    and  BANK_ACCOUNT_ID = p_bank_account_id;
  ELSIF (p_interest_schedule_id is not null and p_bank_account_id is null) THEN
    UPDATE CE_BANK_ACCOUNTS
    SET INTEREST_SCHEDULE_ID = NULL
    WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id;

  END IF;

  IF (p_interest_schedule_id is not null ) THEN
    OPEN SCHED_XTR_ACCTS(p_interest_schedule_id, p_bank_account_id);
    LOOP
      FETCH SCHED_XTR_ACCTS into   X_BANK_ACCOUNT_ID;
      EXIT WHEN sched_xtr_accts%NOTFOUND OR sched_xtr_accts%NOTFOUND IS NULL;

	xtr_schedule_update(p_ce_bank_account_id 	=> X_BANK_ACCOUNT_ID,
			   	p_interest_rounding 	=> null,
				p_interest_includes 	=> null,
				p_basis 		=> null,
				p_day_count_basis 	=> null,
				x_return_status 	=> x_return_status,
				x_msg_count	 	=> x_msg_count,
				x_msg_data	 	=> x_msg_data);
    END LOOP; -- SCHED_XTR_ACCTS
    CLOSE SCHED_XTR_ACCTS;
  END IF;
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

  IF x_msg_count > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END IF;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.remove_schedule_account');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.remove_schedule_account');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.remove_schedule_account');
    fnd_msg_pub.add;
END remove_schedule_account;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      assign_schedule_account	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl (ScheduleBankAcctPG/CO)                           |
|                                                                       |
|  DESCRIPTION                                                          |
|      assign bank accounts for the interest schedule			|
|        CE_BANK_ACCOUNTS			                        |
 --------------------------------------------------------------------- */
PROCEDURE  assign_schedule_account(p_interest_schedule_id IN 	number,
				   p_bank_account_id 	  IN	number,
			   	   p_basis 		  IN 	varchar2,
			   	   p_interest_includes 	  IN 	varchar2,
			   	   p_interest_rounding 	  IN 	varchar2,
			  	   p_day_count_basis 	  IN 	varchar2,
			      	   x_return_status        IN OUT NOCOPY VARCHAR2,
    			      	   x_msg_count               OUT NOCOPY NUMBER,
			      	   x_msg_data                OUT NOCOPY VARCHAR2
				)  IS

 x_bank_account_id  	NUMBER;
 x_ba_count	  	NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.assign_schedule_account');
  END IF;
  -- initialize API return status to success.
  x_return_status := fnd_api.g_ret_sts_success;

  IF (p_interest_schedule_id is not null ) THEN
    SELECT count(1)
    into x_ba_count
    from  CE_BANK_ACCOUNTS
    WHERE
      nvl(interest_schedule_id, 1) =  p_interest_schedule_id
    and bank_account_id = p_bank_account_id;

    IF (x_ba_count > 0)  THEN
      FND_MESSAGE.Set_Name('CE', 'CE_ACCT_IS_ASSIGNED');
      --FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.assign_schedule_account');
      fnd_msg_pub.add;
    ELSE
      UPDATE CE_BANK_ACCOUNTS
      SET INTEREST_SCHEDULE_ID = p_interest_schedule_id
      WHERE INTEREST_SCHEDULE_ID is null
      and  BANK_ACCOUNT_ID = p_bank_account_id;

      OPEN SCHED_XTR_ACCTS(p_interest_schedule_id,  p_bank_account_id);
      LOOP
        FETCH SCHED_XTR_ACCTS into   X_BANK_ACCOUNT_ID;
        EXIT WHEN sched_xtr_accts%NOTFOUND OR sched_xtr_accts%NOTFOUND IS NULL;

	  xtr_schedule_update(p_ce_bank_account_id 	=> X_BANK_ACCOUNT_ID,
			   	p_interest_rounding 	=> p_interest_rounding,
				p_interest_includes 	=> p_interest_includes,
				p_basis 		=> p_basis,
				p_day_count_basis 	=> p_day_count_basis,
				x_return_status 	=> x_return_status,
				x_msg_count	 	=> x_msg_count,
				x_msg_data	 	=> x_msg_data);
      END LOOP; -- SCHED_XTR_ACCTS
      CLOSE SCHED_XTR_ACCTS;

    END IF;
  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_INTEREST_SCHED_PKG.assign_schedule_account INTEREST_SCHEDULE_ID missing');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_INT_SCHED_ID_MISSING');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.assign_schedule_account');
    fnd_msg_pub.add;
  END IF;

  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

  IF x_msg_count > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.assign_schedule_account');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.assign_schedule_account');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.assign_schedule_account');
    fnd_msg_pub.add;
END assign_schedule_account;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      delete_interest_rates
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl (populateIntRate)    	                        |
|      delete_schedule                                                  |
|  DESCRIPTION                                                          |
|      delete interest_rates from
|        CE_INTEREST_RATES			                        |
 --------------------------------------------------------------------- */
PROCEDURE  delete_interest_rates(p_interest_schedule_id number,
				 p_effective_date date) IS

 x_bank_account_id  	NUMBER;
 x_interest_rate_count 	NUMBER;
 BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.delete_interest_rates');
  END IF;

  IF (p_effective_date is not null) THEN
    select count(*)
    into x_interest_rate_count
    from  CE_INTEREST_RATES
      WHERE BALANCE_RANGE_ID in (SELECT BALANCE_RANGE_ID FROM CE_INTEREST_BAL_RANGES
				WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id)
      and EFFECTIVE_DATE = p_effective_date;

    -- make sure at least one transaction exist
    IF (x_interest_rate_count < 1) THEN

      FND_MESSAGE.Set_Name('CE', 'CE_INT_RATE_DATE_NOT_EXIST');
      FND_MESSAGE.Set_Token('EFFECTIVE_DATE',p_effective_date );
      fnd_msg_pub.add;
    END IF;
  END IF;
  IF (p_interest_schedule_id is not null and p_effective_date is not null)  THEN
    DELETE FROM CE_INTEREST_RATES
    WHERE BALANCE_RANGE_ID in (SELECT BALANCE_RANGE_ID FROM CE_INTEREST_BAL_RANGES
				WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id)
    and EFFECTIVE_DATE = p_effective_date;

  ELSIF (p_interest_schedule_id is not null and p_effective_date is  null)  THEN
    DELETE FROM CE_INTEREST_RATES
    WHERE BALANCE_RANGE_ID in (SELECT BALANCE_RANGE_ID FROM CE_INTEREST_BAL_RANGES
				WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id);

  END IF;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.delete_interest_rates');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.delete_interest_rates');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.delete_interest_rates');
    fnd_msg_pub.add;
END delete_interest_rates;
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      delete_bal_ranges;
|                                                                       |
|  CALLED BY                                                            |
|      delete_schedule
|                                                                       |
|  DESCRIPTION                                                          |
|      delete all balance ranges for a schedule
|
 --------------------------------------------------------------------- */
PROCEDURE  delete_bal_ranges(  	p_interest_schedule_id number) IS
  BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.delete_bal_ranges');
  END IF;

  IF (p_interest_schedule_id is not null)  THEN
    DELETE FROM CE_INTEREST_BAL_RANGES
    WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id;

  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.delete_bal_ranges');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.delete_bal_ranges');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.delete_bal_ranges');
    fnd_msg_pub.add;
END delete_bal_ranges;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      delete_schedule
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl (deleteIntSchedInfo)    	                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      delete all schedule related information
|
 --------------------------------------------------------------------- */
PROCEDURE  delete_schedule(p_interest_schedule_id IN	number,
			   x_return_status	  IN OUT NOCOPY VARCHAR2,
    			   x_msg_count      	     OUT NOCOPY NUMBER,
			   x_msg_data       	     OUT NOCOPY VARCHAR2
		) IS
p_effective_date date ;
p_bank_account_id number;
  BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.delete_schedule');
  END IF;
  -- initialize API return status to success.
  x_return_status := fnd_api.g_ret_sts_success;

  p_effective_date  := null;
  p_bank_account_id := null;
  IF (p_interest_schedule_id is not null ) THEN

    --deleteIntSchedule(interestScheduleId);
    -- handle in OA
    --deleteIntBalRanges(interestScheduleId);
    delete_bal_ranges(p_interest_schedule_id);

    --deleteIntRate(interestScheduleId);
    delete_interest_rates(p_interest_schedule_id, p_effective_date);

    --deleteIntBankAcct(interestScheduleId);
    remove_schedule_account(p_interest_schedule_id, p_bank_account_id,
				 x_return_status,
    			      	 x_msg_count,
			      	 x_msg_data);

  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_INTEREST_SCHED_PKG.delete_schedule INTEREST_SCHEDULE_ID missing');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_INT_SCHED_ID_MISSING');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.delete_schedule');
    fnd_msg_pub.add;
  END IF;

  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

  IF x_msg_count > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.delete_schedule');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.delete_schedule');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.delete_schedule');
    fnd_msg_pub.add;
END delete_schedule;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      update_schedule
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl (updateIntSchedInfo)    	                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      call xtr API when schedule related information has changed
|
 --------------------------------------------------------------------- */
PROCEDURE  update_schedule(p_interest_schedule_id IN 	number,
			   p_basis 		  IN 	varchar2,
			   p_interest_includes 	  IN 	varchar2,
			   p_interest_rounding 	  IN 	varchar2,
			   p_day_count_basis 	  IN 	varchar2,
			   x_return_status	  IN OUT NOCOPY VARCHAR2,
    			   x_msg_count      	     OUT NOCOPY NUMBER,
			   x_msg_data       	     OUT NOCOPY VARCHAR2
		) IS

  X_DAY_COUNT_BASIS	VARCHAR(30);
  X_INTEREST_INCLUDES	VARCHAR(30);
  X_INTEREST_ROUNDING	VARCHAR(30);
  X_BASIS		VARCHAR(30);
  X_BANK_ACCOUNT_ID	NUMBER;
  --X_return_status

  BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_SCHED_PKG.update_schedule');
  END IF;
  -- initialize API return status to success.
  x_return_status := fnd_api.g_ret_sts_success;

  IF (p_interest_schedule_id is not null ) THEN

    select
      DAY_COUNT_BASIS,
      INTEREST_INCLUDES,
      INTEREST_ROUNDING,
      BASIS
    into
      X_DAY_COUNT_BASIS,
      X_INTEREST_INCLUDES,
      X_INTEREST_ROUNDING,
      X_BASIS
    from ce_interest_schedules
    where INTEREST_SCHEDULE_ID = p_interest_schedule_id;


    IF ((X_DAY_COUNT_BASIS <> p_day_count_basis ) or
        (X_INTEREST_INCLUDES <> p_interest_includes) or
        (X_INTEREST_ROUNDING <> p_interest_rounding) or
        (X_BASIS  <> p_basis )) THEN

      OPEN SCHED_XTR_ACCTS(p_interest_schedule_id, null);
      LOOP
        FETCH SCHED_XTR_ACCTS into   X_BANK_ACCOUNT_ID;
        EXIT WHEN sched_xtr_accts%NOTFOUND OR sched_xtr_accts%NOTFOUND IS NULL;

	  xtr_schedule_update(p_ce_bank_account_id 	=> X_BANK_ACCOUNT_ID,
			   	p_interest_rounding 	=> p_interest_rounding,
				p_interest_includes 	=> p_interest_includes,
				p_basis 		=> p_basis,
				p_day_count_basis 	=> p_day_count_basis,
				x_return_status 	=> x_return_status,
				x_msg_count	 	=> x_msg_count,
				x_msg_data	 	=> x_msg_data);

      END LOOP; -- SCHED_XTR_ACCTS
      CLOSE SCHED_XTR_ACCTS;

    END IF;
  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_INTEREST_SCHED_PKG.update_schedule INTEREST_SCHEDULE_ID missing');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_INT_SCHED_ID_MISSING');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.update_schedule');
    fnd_msg_pub.add;
  END IF;

  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

  IF x_msg_count > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_SCHED_PKG.update_schedule');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_SCHED_PKG.update_schedule');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_SCHED_PKG.update_schedule');
    fnd_msg_pub.add;
END update_schedule;

END CE_INTEREST_SCHED_PKG;

/
