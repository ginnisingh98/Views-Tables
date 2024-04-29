--------------------------------------------------------
--  DDL for Package Body CSE_IFA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_IFA_TRANS_PKG" AS
-- $Header: CSEIFATB.pls 120.0 2005/05/24 17:40:48 appldev noship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

--===========================================================================
-- | PROCEDURE                                                                 |
-- |                                                                           |
-- |      TRANSFER_FA_DISTRIBUTION                                             |
-- |                                                                           |
-- | DESCRIPTION                                                               |
-- |                                                                           |
-- |      This procedure transfers units from a distribution of an asset to    |
-- |      another within the same asset. If the destination distribution does  |
-- |      not exist, it will be created during the transfer.                   |
-- |                                                                           |
-- |      If the transfer is successful, P_RETURN_STATUS will be set to        |
-- |      FND_API.G_RET_STS_SUCCESS and P_ERROR_MSG will be NULL. Otherwise,   |
-- |      P_RETURN_STATUS will be set to FND_API.G_RET_STS_ERROR and           |
-- |      P_ERROR_MSG will contain the error description.                      |
-- |                                                                           |
-- |      The new from distribution id and new to distribution id will be      |
-- |      returned after the transfer is completed successfully.               |
-- |                                                                           |
-- +===========================================================================

PROCEDURE transfer_fa_distribution
    (p_asset_id              IN NUMBER,
     p_book_type_code        IN VARCHAR2,
     p_units                 IN NUMBER,
     p_from_location_id      IN NUMBER,
     p_from_expense_ccid     IN NUMBER,
     p_from_employee_id      IN NUMBER ,
     p_to_location_id        IN NUMBER,
     p_to_expense_ccid       IN NUMBER,
     p_to_employee_id        IN NUMBER ,
     x_new_from_dist_id      OUT NOCOPY NUMBER,
     x_new_to_dist_id        OUT NOCOPY NUMBER,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_error_msg             OUT NOCOPY VARCHAR2
    ) IS
l_from_units       NUMBER;
l_seq_num          NUMBER;
l_user_id          NUMBER := fnd_global.user_id;
l_login_id         NUMBER := fnd_global.login_id;
l_status           VARCHAR2(10) := FND_API.G_RET_STS_ERROR;
l_msg_count        NUMBER := 0;
l_msg_data         VARCHAR2(1024) := NULL;
l_new_from_dist_id NUMBER;
l_new_to_dist_id   NUMBER;
l_fnd_msg_count    NUMBER := 0;
l_temp_str         VARCHAR2(1024) := NULL;
MOD_DIST_FAIL      EXCEPTION;
l_api_name         VARCHAR2(100) := 'CSE_IFA_TRANS_PKG.transfer_fa_distribution';
l_msg_index        NUMBER ;
BEGIN

  cse_util_pkg.write_log('Performing FA distribution transfer.');

  l_from_units := -p_units;

  -- Select sequence number
  select fa_mass_external_transfers_s.nextval
  into l_seq_num
  from dual;

  -- Insert the FROM record into the FA_MASS_EXTERNAL_TRANSFERS interface table

  cse_util_pkg.write_log('Inserting record with MASS_EXTERNAL_TRANSFER_ID ' ||
                    l_seq_num);

  INSERT INTO fa_mass_external_transfers(batch_name,
                                         mass_external_transfer_id,
                                         transaction_reference_num,
                                         transaction_type,
                                         from_asset_id,
                                         book_type_code,
                                         transaction_status,
                                         from_location_id,
                                         from_gl_ccid,
                                         from_employee_id,
                                         transfer_units,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_login,
                                         last_updated_date,
                                         last_update_date)
  VALUES('FA_MODIFY_DISTS',
         l_seq_num,
         1,
         'TRANSFER',
         p_asset_id,
         p_book_type_code,
         'POST',
         p_from_location_id,
         p_from_expense_ccid,
         p_from_employee_id,
         l_from_units,
         l_user_id,
         sysdate,
         l_user_id,
         l_login_id,
         sysdate,
         sysdate);

  -- Select sequence number
  select fa_mass_external_transfers_s.nextval
  into l_seq_num
  from dual;

  -- Insert the TO record into the FA_MASS_EXTERNAL_TRANSFERS interface table

  cse_util_pkg.write_log('Inserting record with MASS_EXTERNAL_TRANSFER_ID ' ||
                    l_seq_num);

  INSERT INTO fa_mass_external_transfers(batch_name,
                                         mass_external_transfer_id,
                                         transaction_reference_num,
                                         transaction_type,
                                         from_asset_id,
                                         book_type_code,
                                         transaction_status,
                                         to_location_id,
                                         to_gl_ccid,
                                         to_employee_id,
                                         transfer_units,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_login,
                                         last_updated_date,
                                         last_update_date)
  VALUES('FA_MODIFY_DISTS',
         l_seq_num,
         1,
         'TRANSFER',
         p_asset_id,
         p_book_type_code,
         'POST',
         p_to_location_id,
         p_to_expense_ccid,
         p_to_employee_id,
         p_units,
         l_user_id,
         sysdate,
         l_user_id,
         l_login_id,
         sysdate,
         sysdate);

  -- Process the records

  fa_modify_distributions_pkg.modify_distributions(
                       p_api_version => 1.0,
                       p_init_msg_list => FND_API.G_TRUE,
                       p_commit => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                       p_debug_flag => 'NO',
                       x_return_status => l_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

  cse_util_pkg.write_log('Status from MODIFY_DISTRIBUTIONS: ' || l_status);
 if (l_status <> FND_API.G_RET_STS_SUCCESS)
 then
     if (l_msg_count > 0)
     then
       l_msg_index := 1;
       x_error_msg :=l_msg_data;
       WHILE l_msg_count > 0
       LOOP
	  x_error_msg :=FND_MSG_PUB.GET(l_msg_index,
          FND_API.G_FALSE)||x_error_msg ;
	      l_msg_index := l_msg_index + 1;
          l_Msg_Count := l_Msg_Count - 1;
       END LOOP;
     end if ;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_new_from_dist_id := NULL;
     x_new_to_dist_id := NULL;
      cse_util_pkg.write_log('Error : '||x_error_msg);
     raise MOD_DIST_FAIL;
  else
     -- Find out the new from distribution id
     cse_util_pkg.write_log(' Find OUT NOCOPY the new from distribution id...');

    begin
     SELECT distribution_id
     INTO l_new_from_dist_id
     FROM fa_distribution_history
     WHERE asset_id = p_asset_id AND
           book_type_code = p_book_type_code AND
           location_id = p_from_location_id AND
           code_combination_id = p_from_expense_ccid AND
           nvl(assigned_to, -1) = nvl(p_from_employee_id, -1) AND
           date_ineffective is null;
    exception
     when NO_DATA_FOUND then
        l_new_from_dist_id := NULL;
    end;

     cse_util_pkg.write_log(' new from distribution id: ' || l_new_from_dist_id);

     -- Find out the new to distribution id

     cse_util_pkg.write_log(' Find OUT NOCOPY the new to distribution id...');

     SELECT distribution_id
     INTO l_new_to_dist_id
     FROM fa_distribution_history
     WHERE asset_id = p_asset_id AND
           book_type_code = p_book_type_code AND
           location_id = p_to_location_id AND
           code_combination_id = p_to_expense_ccid AND
           nvl(assigned_to, -1) = nvl(p_to_employee_id, -1) AND
           date_ineffective is null;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_error_msg := NULL;
     x_new_from_dist_id := l_new_from_dist_id;
     x_new_to_dist_id := l_new_to_dist_id;

     cse_util_pkg.write_log(' new to distribution id: ' || l_new_to_dist_id);

  end if;

EXCEPTION

  WHEN MOD_DIST_FAIL THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
     fnd_message.set_token('API_NAME',l_api_name);
     x_new_from_dist_id := NULL;
     x_new_to_dist_id := NULL;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_msg := sqlerrm;
     x_new_from_dist_id := NULL;
     x_new_to_dist_id := NULL;

END transfer_fa_distribution;


-- ===========================================================================+
-- | PROCEDURE                                                                 |
-- |                                                                           |
-- |      ADJUST_FA_DISTRIBUTION                                               |
-- |                                                                           |
-- | DESCRIPTION                                                               |
-- |                                                                           |
-- |      This procedure adjusts the units of an existing distribution in an   |
-- |      asset and adjusts the total units of the asset accordingly.          |
-- |                                                                           |
-- |      For unit increase, P_UNITS must be positive. For unit decrease,      |
-- |      P_UNITS must be negative.                                            |
-- |                                                                           |
-- |      If the adjustment is successful, P_RETURN_STATUS will be set to      |
-- |      FND_API.G_RET_STS_SUCCESS and P_ERROR_MSG will be NULL. Otherwise,   |
-- |      P_RETURN_STATUS will be set to FND_API.G_RET_STS_ERROR and           |
-- |      P_ERROR_MSG will contain the error description.                      |
-- |                                                                           |
-- |      The new distribution id of the adjusted distribution will be         |
-- |      returned after the adjustment is completed successfully.             |
-- |                                                                           |
-- +===========================================================================

PROCEDURE adjust_fa_distribution
    (p_asset_id              IN NUMBER,
     p_book_type_code        IN VARCHAR2,
     p_units                 IN NUMBER,
     p_location_id           IN NUMBER,
     p_expense_ccid          IN NUMBER,
     p_employee_id           IN NUMBER ,
     x_new_dist_id           OUT NOCOPY NUMBER,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_error_msg             OUT NOCOPY VARCHAR2
    ) IS
l_from_units       NUMBER;
l_seq_num          NUMBER;
l_user_id          NUMBER := fnd_global.user_id;
l_login_id         NUMBER := fnd_global.login_id;
l_status           VARCHAR2(10) := FND_API.G_RET_STS_ERROR;
l_msg_count        NUMBER := 0;
l_msg_data         VARCHAR2(1024) := NULL;
l_temp_dist_id     NUMBER;
l_new_dist_id      NUMBER;
l_new_from_dist_id NUMBER;
l_new_to_dist_id   NUMBER;
l_fnd_msg_count    NUMBER := 0;
l_temp_str         VARCHAR2(1024) := NULL;
l_location_id      NUMBER;
l_expense_ccid     NUMBER;
l_employee_id      NUMBER;
l_update_status    VARCHAR2(10);
l_update_err_msg   VARCHAR2(1024);
NO_DIST_EXISTS     EXCEPTION;
UPDATE_FAIL        EXCEPTION;
MOD_DIST_FAIL      EXCEPTION;
l_api_name         VARCHAR2(100) := 'CSE_IFA_TRANS_PKG.adjust_fa_distribution' ;
l_msg_index        NUMBER ;
CURSOR c_dist1 IS
     SELECT distribution_id
     FROM fa_distribution_history
     WHERE asset_id = p_asset_id AND
           book_type_code = p_book_type_code AND
           location_id = p_location_id AND
           code_combination_id = p_expense_ccid AND
           nvl(assigned_to, -1) = nvl(p_employee_id, -1) AND
           date_ineffective is null;
CURSOR c_dist2 IS
     SELECT distribution_id
     FROM fa_distribution_history
     WHERE asset_id = p_asset_id AND
           book_type_code = p_book_type_code AND
           date_ineffective is null;
BEGIN

  cse_util_pkg.write_log('Performing FA distribution unit adjustment.');

  -- Determine if the distribution exists or not

  open c_dist1;
  fetch c_dist1 into l_temp_dist_id;

  if (c_dist1%NOTFOUND) then -- Distribution does not exist
    close c_dist1;
    if (p_units < 0) then
      cse_util_pkg.write_log('FA distribution does not exist for negative unit adjustment.');
      raise NO_DIST_EXISTS;
    end if;

    -- Pick an existing distribution to do an adjustment first and then a transfer
    open c_dist2;
    fetch c_dist2 into l_temp_dist_id;
    if (c_dist2%NOTFOUND) then -- No valid distribution for the asset

      close c_dist2;
      cse_util_pkg.write_log('No FA distribution exists for the asset to do unit adjustment.');
      raise NO_DIST_EXISTS;

    else

      close c_dist2;

      cse_util_pkg.write_log('Need to create a new distribution during unit adjustment.');
      cse_util_pkg.write_log('A unit adjustment will first be done followed by a transfer.');

      -- First perform a unit adjustment

      select location_id,
             code_combination_id,
             assigned_to
      into l_location_id,
           l_expense_ccid,
           l_employee_id
      from fa_distribution_history
      where distribution_id = l_temp_dist_id;

      select fa_mass_external_transfers_s.nextval
      into l_seq_num
      from dual;

      cse_util_pkg.write_log('Inserting record with MASS_EXTERNAL_TRANSFER_ID ' ||
                        l_seq_num);

      INSERT INTO fa_mass_external_transfers(batch_name,
                                             mass_external_transfer_id,
                                             transaction_reference_num,
                                             transaction_type,
                                             from_asset_id,
                                             book_type_code,
                                             transaction_status,
                                             to_location_id,
                                             to_gl_ccid,
                                             to_employee_id,
                                             transfer_units,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_login,
                                             last_updated_date,
                                             last_update_date)
      VALUES('FA_MODIFY_DISTS',
             l_seq_num,
             1,
             'UNIT ADJUSTMENT',
             p_asset_id,
             p_book_type_code,
             'POST',
             l_location_id,
             l_expense_ccid,
             l_employee_id,
             p_units,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             sysdate);

      -- Then perform a transfer

      l_from_units := -p_units;

      -- Select sequence number
      select fa_mass_external_transfers_s.nextval
      into l_seq_num
      from dual;

      -- Insert the FROM record into the FA_MASS_EXTERNAL_TRANSFERS interface table

      cse_util_pkg.write_log('Inserting record with MASS_EXTERNAL_TRANSFER_ID ' ||
                        l_seq_num);

      INSERT INTO fa_mass_external_transfers(batch_name,
                                             mass_external_transfer_id,
                                             transaction_reference_num,
                                             transaction_type,
                                             from_asset_id,
                                             book_type_code,
                                             transaction_status,
                                             from_location_id,
                                             from_gl_ccid,
                                             from_employee_id,
                                             transfer_units,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_login,
                                             last_updated_date,
                                             last_update_date)
      VALUES('FA_MODIFY_DISTS',
             l_seq_num,
             2,
             'TRANSFER',
             p_asset_id,
             p_book_type_code,
             'POST',
             l_location_id,
             l_expense_ccid,
             l_employee_id,
             l_from_units,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             sysdate);

      -- Select sequence number
      select fa_mass_external_transfers_s.nextval
      into l_seq_num
      from dual;

      -- Insert the TO record into the FA_MASS_EXTERNAL_TRANSFERS interface table

      cse_util_pkg.write_log('Inserting record with MASS_EXTERNAL_TRANSFER_ID ' ||
                        l_seq_num);

      INSERT INTO fa_mass_external_transfers(batch_name,
                                             mass_external_transfer_id,
                                             transaction_reference_num,
                                             transaction_type,
                                             from_asset_id,
                                             book_type_code,
                                             transaction_status,
                                             to_location_id,
                                             to_gl_ccid,
                                             to_employee_id,
                                             transfer_units,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_login,
                                             last_updated_date,
                                             last_update_date)
      VALUES('FA_MODIFY_DISTS',
             l_seq_num,
             2,
             'TRANSFER',
             p_asset_id,
             p_book_type_code,
             'POST',
             p_location_id,
             p_expense_ccid,
             p_employee_id,
             p_units,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             sysdate);

      -- Process the records

      fa_modify_distributions_pkg.modify_distributions(
                       p_api_version => 1.0,
                       p_init_msg_list => FND_API.G_TRUE,
                       p_commit => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                       p_debug_flag => 'NO',
                       x_return_status => l_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

      cse_util_pkg.write_log('Status from MODIFY_DISTRIBUTIONS: ' || l_status);

      if (l_status <> FND_API.G_RET_STS_SUCCESS)
      then
         if (l_msg_count > 0)
         then
           l_msg_index := 1;
           x_error_msg :=l_msg_data;
           WHILE l_msg_count > 0
           LOOP
	      x_error_msg :=FND_MSG_PUB.GET(l_msg_index,
              FND_API.G_FALSE)||x_error_msg ;
	      l_msg_index := l_msg_index + 1;
              l_Msg_Count := l_Msg_Count - 1;
           END LOOP;
         end if ;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_new_dist_id := NULL;
      cse_util_pkg.write_log('Error : '||x_error_msg);
     raise MOD_DIST_FAIL;

    else
         -- Find out the new id for the temp distribution

         SELECT distribution_id
         INTO l_new_dist_id
         FROM fa_distribution_history
         WHERE asset_id = p_asset_id AND
               book_type_code = p_book_type_code AND
               location_id = l_location_id AND
               code_combination_id = l_expense_ccid AND
               nvl(assigned_to, -1) = nvl(l_employee_id, -1) AND
               date_ineffective is null;


         -- Find out the new distribution id

         SELECT distribution_id
         INTO l_new_dist_id
         FROM fa_distribution_history
         WHERE asset_id = p_asset_id AND
               book_type_code = p_book_type_code AND
               location_id = p_location_id AND
               code_combination_id = p_expense_ccid AND
               nvl(assigned_to, -1) = nvl(p_employee_id, -1) AND
               date_ineffective is null;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_error_msg := NULL;
         x_new_dist_id := l_new_dist_id;

      end if;

    end if; -- End picking a random distribution

  else -- Distribution exists
    close c_dist1;

    -- Select sequence number

    select fa_mass_external_transfers_s.nextval
    into l_seq_num
    from dual;

    -- Insert the record into the FA_MASS_EXTERNAL_TRANSFERS interface table

    cse_util_pkg.write_log('Distribution exists. Inserting record with MASS_EXTERNAL_TRANSFER_ID ' || l_seq_num);

    if (p_units < 0) then -- Subtracting

      INSERT INTO fa_mass_external_transfers(batch_name,
                                             mass_external_transfer_id,
                                             transaction_reference_num,
                                             transaction_type,
                                             from_asset_id,
                                             book_type_code,
                                             transaction_status,
                                             from_location_id,
                                             from_gl_ccid,
                                             from_employee_id,
                                             transfer_units,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_login,
                                             last_updated_date,
                                             last_update_date)
      VALUES('FA_MODIFY_DISTS',
             l_seq_num,
             1,
             'UNIT ADJUSTMENT',
             p_asset_id,
             p_book_type_code,
             'POST',
             p_location_id,
             p_expense_ccid,
             p_employee_id,
             p_units,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             sysdate);

    elsif (p_units > 0) then -- Adding

      INSERT INTO fa_mass_external_transfers(batch_name,
                                             mass_external_transfer_id,
                                             transaction_reference_num,
                                             transaction_type,
                                             from_asset_id,
                                             book_type_code,
                                             transaction_status,
                                             to_location_id,
                                             to_gl_ccid,
                                             to_employee_id,
                                             transfer_units,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_login,
                                             last_updated_date,
                                             last_update_date)
      VALUES('FA_MODIFY_DISTS',
             l_seq_num,
             1,
             'UNIT ADJUSTMENT',
             p_asset_id,
             p_book_type_code,
             'POST',
             p_location_id,
             p_expense_ccid,
             p_employee_id,
             p_units,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             sysdate);

    end if;

    -- Process the records

    fa_modify_distributions_pkg.modify_distributions(
                         p_api_version => 1.0,
                         p_init_msg_list => FND_API.G_TRUE,
                         p_commit => FND_API.G_FALSE,
                         p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                         p_debug_flag => 'NO',
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

    cse_util_pkg.write_log('Status from MODIFY_DISTRIBUTIONS: ' || l_status);

    if (l_status <> FND_API.G_RET_STS_SUCCESS)
    then
         if (l_msg_count > 0)
         then
           l_msg_index := 1;
           x_error_msg :=l_msg_data;
           WHILE l_msg_count > 0
           LOOP
	      x_error_msg :=FND_MSG_PUB.GET(l_msg_index,
              FND_API.G_FALSE)||x_error_msg ;
	      l_msg_index := l_msg_index + 1;
              l_Msg_Count := l_Msg_Count - 1;
           END LOOP;
         end if ;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_new_dist_id := NULL;
     cse_util_pkg.write_log('Error : '||x_error_msg);
     raise MOD_DIST_FAIL;

    else
       -- Find out the new distribution id
      begin
       SELECT distribution_id
       INTO l_new_dist_id
       FROM fa_distribution_history
       WHERE asset_id = p_asset_id AND
             book_type_code = p_book_type_code AND
             location_id = p_location_id AND
             code_combination_id = p_expense_ccid AND
             nvl(assigned_to, -1) = nvl(p_employee_id, -1) AND
             date_ineffective is null;
      exception
       when NO_DATA_FOUND then
          l_new_dist_id := NULL;
      end;

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_error_msg := NULL;
       x_new_dist_id := l_new_dist_id;

    end if;

  end if; -- Check if distribution exists

EXCEPTION

  WHEN NO_DIST_EXISTS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('CSE', 'CSE_NO_FA_DIST_FOR_ADJ');
     x_error_msg := fnd_message.get;
     x_new_dist_id := NULL;

  WHEN UPDATE_FAIL THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_msg := l_update_err_msg;
     x_new_dist_id := NULL;

  WHEN MOD_DIST_FAIL THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
     fnd_message.set_token('API_NAME',l_api_name);
     x_error_msg := fnd_message.get;
     x_new_dist_id := NULL;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_msg := sqlerrm;
     x_new_dist_id := NULL;

END adjust_fa_distribution;

END CSE_IFA_TRANS_PKG;

/
