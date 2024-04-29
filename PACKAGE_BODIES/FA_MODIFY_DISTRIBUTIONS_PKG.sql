--------------------------------------------------------
--  DDL for Package Body FA_MODIFY_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MODIFY_DISTRIBUTIONS_PKG" as
/* $Header: FAMDSTB.pls 120.4.12010000.2 2009/07/19 14:35:32 glchen ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

  PROCEDURE modify_distributions(
        P_api_version      IN  NUMBER,
        P_init_msg_list    IN  VARCHAR2,
        P_commit           IN  VARCHAR2,
        P_validation_level IN  NUMBER,
        P_debug_flag       IN  VARCHAR2,
        X_return_status    OUT NOCOPY VARCHAR2,
        X_msg_count        OUT NOCOPY NUMBER,
        X_msg_data         OUT NOCOPY VARCHAR2) IS

    G_PKG_NAME          CONSTANT VARCHAR2(30) := 'FA_MODIFY_DISTRIBUTIONS_PKG';
    l_api_name          CONSTANT VARCHAR2(30) := 'Modify_Distributions';
    l_api_version       CONSTANT NUMBER := 1.0;

    l_met_c_open                BOOLEAN      := FALSE;
    l_last_fetch                BOOLEAN      := FALSE;
    l_assignments_completed     BOOLEAN      := FALSE;

    l_book_type_code            VARCHAR2(30) := NULL;
    l_asset_id                  NUMBER       := 0;
    l_trx_reference_num         NUMBER       := -1;
    l_trx_type                  VARCHAR2(15) := NULL;

    l_return_status             VARCHAR2(10) := FND_API.G_RET_STS_ERROR;
    l_transaction_status        VARCHAR2(20) := 'ERRORED';

    CURSOR MET_C IS
        SELECT   MET.rowid row_id, MET.*
        FROM     fa_mass_external_transfers MET
        WHERE    MET.batch_name = 'FA_MODIFY_DISTS'
        AND      MET.transaction_status = 'POST'
        AND      MET.transaction_type in ('UNIT ADJUSTMENT', 'TRANSFER')
        ORDER BY MET.BOOK_TYPE_CODE,
                 MET.FROM_ASSET_ID,
                 MET.TRANSACTION_REFERENCE_NUM,
                 MET.TRANSACTION_TYPE;

    METInfo MET_C%ROWTYPE;

  BEGIN

--- int_debug.enable;
--- int_debug.print('Entered modify_distributions ');

    X_return_status := FND_API.G_RET_STS_SUCCESS;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end if;

    -- Standard start of API savepoint.
    ---SAVEPOINT Modify_Dist_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
           l_api_name, G_PKG_NAME)
    THEN
       X_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       -- Initialize error message stack.
       FA_SRVR_MSG.Init_Server_Message;

       -- Initialize debug message stack.
       FA_DEBUG_PKG.Initialize;
    END IF;

    -- Override FA:PRINT_DEBUG profile option.
    IF (p_debug_flag = 'YES') THEN
       FA_DEBUG_PKG.Set_Debug_Flag;
    END IF;

    g_asgn_count := 0;
    asgn_table.delete;
    l_book_type_code    := NULL;
    l_asset_id          := 0;
    l_trx_reference_num := -1;
    l_trx_type          := NULL;

    OPEN  MET_C;
    l_met_c_open := TRUE;

    LOOP  -- begin for each row in fa_mass_external_transfers

    FETCH MET_C
    INTO  METInfo;

    if (MET_C%NOTFOUND) then

        CLOSE MET_C;
        l_met_c_open := FALSE;

        l_last_fetch := TRUE;
        l_assignments_completed := TRUE;

    elsif ((l_book_type_code <> METInfo.book_type_code) OR
           (l_asset_id <> METInfo.from_asset_id) OR
           (l_trx_reference_num <> METInfo.transaction_reference_num) OR
           (l_trx_type <> METInfo.transaction_type)) then

        l_last_fetch            := FALSE;
        l_assignments_completed := TRUE;

    else

        l_last_fetch            := FALSE;
        l_assignments_completed := FALSE;

    end if;

    if ((l_assignments_completed = TRUE) AND (g_asgn_count > 0)) then

         -- process transaction type

         if (l_trx_type = 'UNIT ADJUSTMENT') then

--- int_debug.print('Calling process_unit_adjustment ');

              l_return_status := process_unit_adjustment(
                         p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         p_commit           => p_commit,
                         p_validation_level => p_validation_level,
                         p_debug_flag       => p_debug_flag,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         book_type_code     => l_book_type_code,
                         asset_id           => l_asset_id,
                         p_Log_level_rec    => g_log_level_rec);

         elsif (l_trx_type = 'TRANSFER') then

--- int_debug.print('Calling process_transfer ');
              l_return_status := process_transfer(
                         p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         p_commit           => p_commit,
                         p_validation_level => p_validation_level,
                         p_debug_flag       => p_debug_flag,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         book_type_code     => l_book_type_code,
                         asset_id           => l_asset_id,
                         p_Log_level_rec    => g_log_level_rec);

         end if;

         if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
             l_transaction_status := 'POSTED';
         else
             l_transaction_status := 'ERRORED';
             X_return_status := FND_API.G_RET_STS_ERROR;
         end if;

         FOR i IN asgn_table.FIRST .. asgn_table.LAST LOOP

             UPDATE fa_mass_external_transfers MET
             SET    MET.transaction_status = l_transaction_status
             WHERE  MET.rowid = asgn_table(i).row_id
             AND    MET.transaction_status = 'POST';

         END LOOP;

         IF FND_API.To_Boolean(p_commit) THEN
           COMMIT WORK;
         END IF;

         g_asgn_count := 0;
         asgn_table.delete;
         FA_LOAD_TBL_PKG.g_dist_count := 0;

    end if;

    if (l_last_fetch = FALSE) then

        if (METInfo.last_update_login is NULL) then
            METInfo.last_update_login := METInfo.last_updated_by;
        end if;

        insert_dist_table( row_id            =>  METInfo.row_id,
                           asset_id          =>  METInfo.from_asset_id,
                           transfer_units    =>  METInfo.transfer_units,
                           transaction_date_entered
                                             =>
                              METInfo.transaction_date_entered,
                           from_dist_id      =>  METInfo.from_distribution_id,
                           from_location_id  =>  METInfo.from_location_id,
                           from_assigned_to  =>  METInfo.from_employee_id,
                           from_ccid         =>  METInfo.from_gl_ccid,
                           to_dist_id        =>  METInfo.to_distribution_id,
                           to_location_id    =>  METInfo.to_location_id,
                           to_assigned_to    =>  METInfo.to_employee_id,
                           to_ccid           =>  METInfo.to_gl_ccid,
                           attribute1        =>  METInfo.attribute1,
                           attribute2        =>  METInfo.attribute2,
                           attribute3        =>  METInfo.attribute3,
                           attribute4        =>  METInfo.attribute4,
                           attribute5        =>  METInfo.attribute5,
                           attribute6        =>  METInfo.attribute6,
                           attribute7        =>  METInfo.attribute7,
                           attribute8        =>  METInfo.attribute8,
                           attribute9        =>  METInfo.attribute9,
                           attribute10       =>  METInfo.attribute10,
                           attribute11       =>  METInfo.attribute11,
                           attribute12       =>  METInfo.attribute12,
                           attribute13       =>  METInfo.attribute13,
                           attribute14       =>  METInfo.attribute14,
                           attribute15       =>  METInfo.attribute15,
                           attribute_category_code
                                       =>  METInfo.attribute_category_code,
                           post_batch_id     =>  METInfo.post_batch_id,
                           last_updated_by   =>  METInfo.last_updated_by,
                           last_update_date  =>  METInfo.last_update_date,
                           last_update_login =>  METInfo.last_update_login,
                           p_Log_level_rec   => g_log_level_rec);

        l_book_type_code    := METInfo.book_type_code;
        l_asset_id          := METInfo.from_asset_id;
        l_trx_reference_num := METInfo.transaction_reference_num;
        l_trx_type          := METInfo.transaction_type;

    end if;

    if (l_last_fetch = TRUE) then

        EXIT; -- exit loop for each row in fa_mass_external_transfers

    end if;

    END LOOP; -- end for each row in fa_mass_external_transfers

  EXCEPTION

      when others then

          X_return_status := FND_API.G_RET_STS_ERROR;

          if (l_met_c_open = TRUE) then
              CLOSE MET_C;
              l_met_c_open := FALSE;
          end if;

  END modify_distributions;

  PROCEDURE insert_dist_table(
        row_id            IN  ROWID,
        asset_id          IN  NUMBER,
        transfer_units    IN  NUMBER,
        transaction_date_entered
                          IN  DATE,
        from_dist_id      IN  NUMBER,
        from_location_id  IN  NUMBER,
        from_assigned_to  IN  NUMBER,
        from_ccid         IN  NUMBER,
        to_dist_id        IN  NUMBER,
        to_location_id    IN  NUMBER,
        to_assigned_to    IN  NUMBER,
        to_ccid           IN  NUMBER,
        attribute1        IN  VARCHAR2,
        attribute2        IN  VARCHAR2,
        attribute3        IN  VARCHAR2,
        attribute4        IN  VARCHAR2,
        attribute5        IN  VARCHAR2,
        attribute6        IN  VARCHAR2,
        attribute7        IN  VARCHAR2,
        attribute8        IN  VARCHAR2,
        attribute9        IN  VARCHAR2,
        attribute10       IN  VARCHAR2,
        attribute11       IN  VARCHAR2,
        attribute12       IN  VARCHAR2,
        attribute13       IN  VARCHAR2,
        attribute14       IN  VARCHAR2,
        attribute15       IN  VARCHAR2,
        attribute_category_code IN  VARCHAR2,
        post_batch_id     IN  NUMBER,
        last_updated_by   IN  NUMBER,
        last_update_date IN  DATE,
        last_update_login IN  NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    X_row_id              ROWID := NULL;
    X_asset_id            NUMBER;
    X_dist_id             NUMBER;
    X_new_dist_id         NUMBER := NULL;
    X_location_id         NUMBER;
    X_assigned_to         NUMBER;
    X_ccid                NUMBER;
    X_record_status       NUMBER;
    x_units               NUMBER;

    CURSOR DH_C IS
        SELECT DH.rowid row_id, DH.*
        FROM   fa_distribution_history DH
        WHERE  DH.asset_id = X_asset_id
        AND    DH.distribution_id = NVL(X_dist_id, DH.distribution_id)
        AND    DH.location_id = NVL(X_location_id, DH.location_id)
        AND    DH.code_combination_id = NVL(X_ccid, DH.code_combination_id)
        AND    NVL(DH.assigned_to, -1) = NVL(X_assigned_to, -1)
        AND    DH.date_ineffective IS NULL;

    DHInfo DH_C%ROWTYPE;

  BEGIN

    if (transfer_units = 0) then

        UPDATE fa_mass_external_transfers MET
        SET    MET.transaction_status = 'IGNORED'
        WHERE  MET.rowid = row_id;

        return;

    end if;

    if ((transfer_units < 0) AND
        ((from_dist_id is NOT NULL) OR
         ((from_ccid is NOT NULL) AND (from_location_id is NOT NULL))
        )
       ) then

        X_asset_id    := asset_id;

        if ((from_ccid is NOT NULL) AND (from_location_id is NOT NULL)) then
            X_dist_id := NULL;
            X_location_id := from_location_id;
            X_ccid        := from_ccid;
            X_assigned_to := from_assigned_to;
        else
            X_dist_id := from_dist_id;
            X_location_id := NULL;
            X_ccid := NULL;
            X_assigned_to := to_assigned_to;
        end if;


        OPEN  DH_C;
        FETCH DH_C
        INTO  DHInfo;

        if (DH_C%NOTFOUND) then
            DHInfo.row_id := X_row_id;
            DHInfo.distribution_id := NULL;
            DHInfo.units_assigned := transfer_units;
            DHInfo.code_combination_id := from_ccid;
            DHInfo.location_id := from_location_id;
            DHInfo.assigned_to := from_assigned_to;
            DHInfo.transaction_header_id_in := NULL;
        end if;

        CLOSE DH_C;

        FA_LOAD_TBL_PKG.load_dist_table(
            p_row_id            => DHInfo.row_id,
            p_dist_id           => DHInfo.distribution_id,
            p_asset_id          => asset_id,
            p_units             => DHInfo.units_assigned,
            p_date_effective    => sysdate,
            p_ccid              => DHInfo.code_combination_id,
            p_location_id       => DHInfo.location_id,
            p_th_id_in          => DHINfo.transaction_header_id_in,
            p_assigned_to       => DHInfo.assigned_to,
            p_trans_units       => transfer_units,
            p_record_status     => 'UPDATE', p_log_level_rec => g_log_level_rec);

        load_asgn_table(
            p_row_id            => row_id,
            p_dist_id           => DHInfo.distribution_id,
            p_asset_id          => asset_id,
            p_units             => DHInfo.units_assigned,
            p_transaction_date_entered
                                => transaction_date_entered,
            p_date_effective    => sysdate,
            p_ccid              => DHInfo.code_combination_id,
            p_location_id       => DHInfo.location_id,
            p_th_id_in          => DHINfo.transaction_header_id_in,
            p_assigned_to       => DHInfo.assigned_to,
            p_trans_units       => transfer_units,
            p_record_status     => 'UPDATE',
            p_attribute1        => attribute1,
            p_attribute2        => attribute2,
            p_attribute3        => attribute3,
            p_attribute4        => attribute4,
            p_attribute5        => attribute5,
            p_attribute6        => attribute6,
            p_attribute7        => attribute7,
            p_attribute8        => attribute8,
            p_attribute9        => attribute9,
            p_attribute10       => attribute10,
            p_attribute11       => attribute11,
            p_attribute12       => attribute12,
            p_attribute13       => attribute13,
            p_attribute14       => attribute14,
            p_attribute15       => attribute15,
            p_attribute_category_code => attribute_category_code,
            p_last_updated_by   => last_updated_by,
            p_last_update_date  => last_update_date,
            p_last_update_login => last_update_login,
            p_Log_level_rec    => g_log_level_rec);

    end if;

    if ((transfer_units > 0) AND
        ((to_dist_id is NOT NULL) OR
         ((to_ccid is NOT NULL) AND (to_location_id is NOT NULL))
        )
       ) then

        X_asset_id    := asset_id;

        if ((to_ccid is NOT NULL) AND (to_location_id is NOT NULL)) then
            X_dist_id := NULL;
            X_location_id := to_location_id;
            X_assigned_to := to_assigned_to;
            X_ccid        := to_ccid;
        else
            X_dist_id := to_dist_id;
            X_location_id := NULL;
            X_ccid := NULL;
            X_assigned_to := to_assigned_to;
        end if;

        OPEN  DH_C;
        FETCH DH_C
        INTO  DHINfo;

        if (DH_C%NOTFOUND) then
            DHInfo.row_id := X_row_id;
            DHInfo.distribution_id := NULL;
            DHInfo.units_assigned := transfer_units;
            DHInfo.code_combination_id := to_ccid;
            DHInfo.location_id := to_location_id;
            DHInfo.assigned_to := to_assigned_to;
            DHInfo.transaction_header_id_in := NULL;
        end if;

        CLOSE DH_C;

        if (DHInfo.distribution_id is NULL) then

            x_units := transfer_units;

            FA_LOAD_TBL_PKG.load_dist_table(
                p_row_id            => X_row_id,
                p_dist_id           => X_new_dist_id,
                p_asset_id          => asset_id,
                p_units             => x_units,
                p_date_effective    => sysdate,
                p_ccid              => to_ccid,
                p_location_id       => to_location_id,
                p_th_id_in          => NULL,
                p_assigned_to       => to_assigned_to,
                p_trans_units       => transfer_units,
                p_record_status     => 'INSERT', p_log_level_rec => g_log_level_rec);

            load_asgn_table(
                p_row_id            => row_id,
                p_dist_id           => X_new_dist_id,
                p_asset_id          => asset_id,
                p_units             => x_units,
                p_transaction_date_entered
                                    => transaction_date_entered,
                p_date_effective    => sysdate,
                p_ccid              => to_ccid,
                p_location_id       => to_location_id,
                p_th_id_in          => NULL,
                p_assigned_to       => to_assigned_to,
                p_trans_units       => transfer_units,
                p_record_status     => 'INSERT',
                p_attribute1        => attribute1,
                p_attribute2        => attribute2,
                p_attribute3        => attribute3,
                p_attribute4        => attribute4,
                p_attribute5        => attribute5,
                p_attribute6        => attribute6,
                p_attribute7        => attribute7,
                p_attribute8        => attribute8,
                p_attribute9        => attribute9,
                p_attribute10       => attribute10,
                p_attribute11       => attribute11,
                p_attribute12       => attribute12,
                p_attribute13       => attribute13,
                p_attribute14       => attribute14,
                p_attribute15       => attribute15,
                p_attribute_category_code => attribute_category_code,
                p_last_updated_by   => last_updated_by,
                p_last_update_date => last_update_date,
                p_last_update_login => last_update_login,
                p_Log_level_rec    => g_log_level_rec);

        else

            FA_LOAD_TBL_PKG.load_dist_table(
                p_row_id            => DHInfo.row_id,
                p_dist_id           => DHInfo.distribution_id,
                p_asset_id          => asset_id,
                p_units             => DHInfo.units_assigned,
                p_date_effective    => sysdate,
                p_ccid              => DHInfo.code_combination_id,
                p_location_id       => DHInfo.location_id,
                p_th_id_in          => DHInfo.transaction_header_id_in,
                p_assigned_to       => DHInfo.assigned_to,
                p_trans_units       => transfer_units,
                p_record_status     => 'UPDATE', p_log_level_rec => g_log_level_rec);

            load_asgn_table(
                p_row_id            => row_id,
                p_dist_id           => DHInfo.distribution_id,
                p_asset_id          => asset_id,
                p_units             => DHInfo.units_assigned,
                p_transaction_date_entered
                                    => transaction_date_entered,
                p_date_effective    => sysdate,
                p_ccid              => DHInfo.code_combination_id,
                p_location_id       => DHInfo.location_id,
                p_th_id_in          => DHInfo.transaction_header_id_in,
                p_assigned_to       => DHInfo.assigned_to,
                p_trans_units       => transfer_units,
                p_record_status     => 'UPDATE',
                p_attribute1        => attribute1,
                p_attribute2        => attribute2,
                p_attribute3        => attribute3,
                p_attribute4        => attribute4,
                p_attribute5        => attribute5,
                p_attribute6        => attribute6,
                p_attribute7        => attribute7,
                p_attribute8        => attribute8,
                p_attribute9        => attribute9,
                p_attribute10       => attribute10,
                p_attribute11       => attribute11,
                p_attribute12       => attribute12,
                p_attribute13       => attribute13,
                p_attribute14       => attribute14,
                p_attribute15       => attribute15,
                p_attribute_category_code => attribute_category_code,
                p_last_updated_by   => last_updated_by,
                p_last_update_date  => last_update_date,
                p_last_update_login => last_update_login,
                p_Log_level_rec    => g_log_level_rec);

        end if;

    end if;

    if (((transfer_units < 0) AND ((from_dist_id is NULL) AND
                 ((from_ccid is NULL) OR (from_location_id is NULL)))) OR
        ((transfer_units > 0) AND ((to_dist_id is NULL) AND
                 ((to_ccid is NULL) OR (to_location_id is NULL))))
       ) then

        UPDATE fa_mass_external_transfers MET
        SET    MET.transaction_status = 'ERRORED'
        WHERE  MET.rowid = row_id;

    end if;

  EXCEPTION

      when others then
        UPDATE fa_mass_external_transfers MET
        SET    MET.transaction_status = 'ERRORED'
        WHERE  MET.rowid = row_id;

  END insert_dist_table;


/* Procedure    load_asgn_table

       Usage    Called by client to load all distributions in the
        global table asgn_line_tbl before calling the API
*/

  PROCEDURE load_asgn_table
         (p_row_id            IN ROWID default null,
          p_dist_id           IN number default null,
          p_asset_id          IN number default null,
          p_units             IN number,
          p_transaction_date_entered
                              IN date,
          p_date_effective    IN date,
          p_ccid              IN number,
          p_location_id       IN number,
          p_th_id_in          IN number,
          p_assigned_to       IN number,
          p_trans_units       IN number,
          p_record_status     IN varchar2,
          p_attribute1        IN varchar2,
          p_attribute2        IN varchar2,
          p_attribute3        IN varchar2,
          p_attribute4        IN varchar2,
          p_attribute5        IN varchar2,
          p_attribute6        IN varchar2,
          p_attribute7        IN varchar2,
          p_attribute8        IN varchar2,
          p_attribute9        IN varchar2,
          p_attribute10       IN varchar2,
          p_attribute11       IN varchar2,
          p_attribute12       IN varchar2,
          p_attribute13       IN varchar2,
          p_attribute14       IN varchar2,
          p_attribute15       IN varchar2,
          p_attribute_category_code
                              IN varchar2,
          p_last_updated_by   IN  NUMBER,
          p_last_update_date  IN  DATE,
          p_last_update_login IN  NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
       if (g_asgn_count=0) then   /* initialize the table */
           asgn_table.delete;
       end if;

       g_asgn_count := g_asgn_count + 1;

       asgn_table(g_asgn_count).row_id := p_row_id;
       asgn_table(g_asgn_count).dist_id := p_dist_id;
       asgn_table(g_asgn_count).asset_id := p_asset_id;
       asgn_table(g_asgn_count).units := p_units;
       asgn_table(g_asgn_count).transaction_date_entered :=
          p_transaction_date_entered;
       asgn_table(g_asgn_count).ccid := p_ccid;
       asgn_table(g_asgn_count).location_id := p_location_id;
       asgn_table(g_asgn_count).th_id_in := p_th_id_in;
       asgn_table(g_asgn_count).assigned_to := p_assigned_to;
       asgn_table(g_asgn_count).trans_units := p_trans_units;
       asgn_table(g_asgn_count).attribute1 := p_attribute1;
       asgn_table(g_asgn_count).attribute2 := p_attribute2;
       asgn_table(g_asgn_count).attribute3 := p_attribute3;
       asgn_table(g_asgn_count).attribute4 := p_attribute4;
       asgn_table(g_asgn_count).attribute5 := p_attribute5;
       asgn_table(g_asgn_count).attribute6 := p_attribute6;
       asgn_table(g_asgn_count).attribute7 := p_attribute7;
       asgn_table(g_asgn_count).attribute8 := p_attribute8;
       asgn_table(g_asgn_count).attribute9 := p_attribute9;
       asgn_table(g_asgn_count).attribute10 := p_attribute10;
       asgn_table(g_asgn_count).attribute11 := p_attribute11;
       asgn_table(g_asgn_count).attribute12 := p_attribute12;
       asgn_table(g_asgn_count).attribute13 := p_attribute13;
       asgn_table(g_asgn_count).attribute14 := p_attribute14;
       asgn_table(g_asgn_count).attribute15 := p_attribute15;
       asgn_table(g_asgn_count).attribute_category_code :=
                                                 p_attribute_category_code;
       asgn_table(g_asgn_count).record_status := p_record_status;
       asgn_table(g_asgn_count).last_updated_by := p_last_updated_by;
       asgn_table(g_asgn_count).last_update_date := p_last_update_date;
       asgn_table(g_asgn_count).last_update_login := p_last_update_login;

  END load_asgn_table;

  FUNCTION process_unit_adjustment(
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        p_debug_flag       IN VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        book_type_code     IN VARCHAR2,
        asset_id           IN NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2
  IS

      h_return_status    VARCHAR2(10) := FND_API.G_RET_STS_ERROR;
      h_msg_count        NUMBER := 0;
      h_msg_data         VARCHAR2(512) := NULL;

      X_asset_id NUMBER;

      CURSOR ADD_C IS
          SELECT   AD.*
          FROM     fa_additions_b AD
          WHERE    AD.asset_id = X_asset_id;

      ADDInfo ADD_C%ROWTYPE;

      X_lease_id NUMBER;

      CURSOR LEA_C IS
          SELECT   LEA.rowid row_id, LEA.*
          FROM     fa_leases LEA
          WHERE    LEA.lease_id = X_lease_id;

      LEAInfo LEA_C%ROWTYPE;

      l_th_row_id                   ROWID          := NULL;
      l_Transaction_Header_Id      NUMBER(15)     := NULL;
      l_Transaction_Date_Entered   DATE;
      l_Max_Transaction_Date       DATE;
      l_Current_PC                   NUMBER(15);
      l_Calendar_Period_Open_Date  DATE;
      l_Calendar_Period_Close_Date DATE;
      l_FY_Start_Date               DATE;
      l_FY_End_Date                   DATE;
      l_total_trans_units          NUMBER;
      l_new_current_units          NUMBER;
      l_return_status              VARCHAR2(15) := FND_API.G_RET_STS_ERROR;

  BEGIN

      -- check that book_type_code is 'CORPORATE' book
      l_return_status := check_if_corp_book(book_type_code => book_type_code,
                                            p_log_level_rec => p_log_level_rec);

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);

      end if;

      X_asset_id := asset_id;

      OPEN  ADD_C;
      FETCH ADD_C
      INTO  ADDInfo;

      if (ADD_C%NOTFOUND) then

        CLOSE ADD_C;

        h_return_status := FND_API.G_RET_STS_ERROR;
        return(h_return_status);

      end if;

      CLOSE ADD_C;

      --- CHECK UNITS and DIST_ID
      l_total_trans_units := 0;

      FOR i IN asgn_table.FIRST .. asgn_table.LAST LOOP

          l_return_status := check_location_ccid(
                                     p_location_id => asgn_table(i).location_id,
                                     p_ccid_id     => asgn_table(i).ccid,
                                     p_log_level_rec => p_log_level_rec);

          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

              h_return_status := FND_API.G_RET_STS_ERROR;
              return(h_return_status);

          end if;

          if ((asgn_table(i).dist_id is NULL) OR
              (asgn_table(i).units + asgn_table(i).trans_units < 0)) then

              h_return_status := FND_API.G_RET_STS_ERROR;
              return(h_return_status);

          end if;

          l_total_trans_units := l_total_trans_units+asgn_table(i).trans_units;

      END LOOP;

      l_new_current_units := l_total_trans_units + ADDInfo.Current_Units;

      if (l_new_current_units < 1) then

          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);

      end if;

      --- Get rest of information
      get_header_info(
            X_Asset_Id                   => asset_id,
            X_Book_Type_Code             => book_type_code,
            X_Transaction_Header_Id      => l_Transaction_Header_Id,
            X_Transaction_Date_Entered   => l_Transaction_Date_Entered,
            X_Max_Transaction_Date       => l_Max_Transaction_Date,
            X_Current_PC                 => l_Current_PC,
            X_Calendar_Period_Open_Date  => l_Calendar_Period_Open_Date,
            X_Calendar_Period_Close_Date => l_Calendar_Period_Close_Date,
            X_FY_Start_Date              => l_FY_Start_Date,
            X_FY_End_Date                => l_FY_End_Date,
            X_return_status              => l_return_status,
            p_log_level_rec              => p_log_level_rec
      );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);

      end if;

      X_lease_id := ADDInfo.lease_id;

      if (X_lease_id is NOT NULL) then

          OPEN  LEA_C;
          FETCH LEA_C
          INTO  LEAInfo;

          if (LEA_C%NOTFOUND) then

            CLOSE LEA_C;

            h_return_status := FND_API.G_RET_STS_ERROR;
            return(h_return_status);

          end if;

          CLOSE LEA_C;

      end if;

      FA_TRANS_API_PUB.Do_Unit_Adjustment(
            -- Standard Parameters --
            p_api_version           => p_api_version,   ----1.0,
            p_init_msg_list         => p_init_msg_list, ----FND_API.G_TRUE,
            p_commit                => p_commit,        ----FND_API.G_TRUE,
            p_validation_level      => p_validation_level,
                                                 ----FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => h_return_status,
            x_msg_count             => h_msg_count,
            x_msg_data              => h_msg_data,
            p_calling_fn            =>
               'fa_modify_distributions_pkg.process_unit_adjustment',
            -- API Options --
            p_debug_flag            => p_debug_flag,    ----'NO',
            -- Out Parameters --
            x_transaction_header_id => l_transaction_header_id,
            -- Transaction Info --
            p_transaction_date_entered =>
               nvl(asgn_table(1).transaction_date_entered,
                   l_Transaction_Date_Entered),
            p_transaction_name      => NULL,
            p_mass_reference_id     => NULL,
            p_calling_interface     => 'FA_MODIFY_DISTS',
            p_last_update_date      => asgn_table(1).last_update_date,
            p_created_by            => asgn_table(1).last_updated_by,
            p_creation_date         => asgn_table(1).last_update_date,
            p_last_updated_by       => asgn_table(1).last_updated_by,
            p_last_update_login     => asgn_table(1).last_update_login,
            p_attribute1            => asgn_table(1).attribute1,
            p_attribute2            => asgn_table(1).attribute2,
            p_attribute3            => asgn_table(1).attribute3,
            p_attribute4            => asgn_table(1).attribute4,
            p_attribute5            => asgn_table(1).attribute5,
            p_attribute6            => asgn_table(1).attribute6,
            p_attribute7            => asgn_table(1).attribute7,
            p_attribute8            => asgn_table(1).attribute8,
            p_attribute9            => asgn_table(1).attribute9,
            p_attribute10           => asgn_table(1).attribute10,
            p_attribute11           => asgn_table(1).attribute11,
            p_attribute12           => asgn_table(1).attribute12,
            p_attribute13           => asgn_table(1).attribute13,
            p_attribute14           => asgn_table(1).attribute14,
            p_attribute15           => asgn_table(1).attribute15,
            p_attribute_category_code
                                    =>
               asgn_table(1).attribute_category_code,
            -- Asset Header Info --
            p_asset_id              => ADDInfo.Asset_Id,
            p_book_type_code        => book_type_code
      );

      x_return_status := h_return_status;
      x_msg_count     := h_msg_count;
      x_msg_data      := h_msg_data;

      if (h_return_status <> FND_API.G_RET_STS_SUCCESS) then
            h_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      return(h_return_status);

  EXCEPTION

      when others then
          h_return_status := FND_API.G_RET_STS_ERROR;
          x_return_status := h_return_status;
          x_msg_count     := h_msg_count;
          x_msg_data      := h_msg_data;

          return(h_return_status);
  END;

  FUNCTION process_transfer(
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        p_debug_flag       IN VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        book_type_code     IN VARCHAR2,
        asset_id           IN NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2
  IS

      h_return_status    VARCHAR2(10) := FND_API.G_RET_STS_ERROR;
      h_msg_count        NUMBER := 0;
      h_msg_data         VARCHAR2(512) := NULL;

      X_asset_id NUMBER;

      CURSOR ADD_C IS
          SELECT   AD.*
          FROM     fa_additions_b AD
          WHERE    AD.asset_id = X_asset_id;

      ADDInfo ADD_C%ROWTYPE;

      l_row_id                     ROWID := NULL;
      l_Transaction_Header_Id      NUMBER(15);
      l_Transaction_Date_Entered   DATE;
      l_Max_Transaction_Date       DATE;
      l_Current_PC                   NUMBER(15);
      l_Calendar_Period_Open_Date  DATE;
      l_Calendar_Period_Close_Date DATE;
      l_FY_Start_Date               DATE;
      l_FY_End_Date                   DATE;
      l_total_trans_units          NUMBER;
      l_return_status              VARCHAR2(15) := FND_API.G_RET_STS_ERROR;
      l_count                      number := 0;
      l_txn_type_code              varchar2(20);
      l_book                       varchar2(30);
      l_asset                      number;

  BEGIN

--- int_debug.print('Entered process_transfer ');

      -- check that book_type_code is 'CORPORATE' book
      l_return_status := check_if_corp_book(book_type_code => book_type_code,
                         p_Log_level_rec    => g_log_level_rec);

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);

      end if;

      X_asset_id := asset_id;

      OPEN  ADD_C;
      FETCH ADD_C
      INTO  ADDInfo;

      if (ADD_C%NOTFOUND) then

        CLOSE ADD_C;

        h_return_status := FND_API.G_RET_STS_ERROR;
        return(h_return_status);

      end if;

      CLOSE ADD_C;

      --- CHECK UNITS and DIST_ID
      l_total_trans_units := 0;

--- int_debug.print('Entered checking table ');

      FOR i IN asgn_table.FIRST .. asgn_table.LAST LOOP

          l_return_status := check_location_ccid(
                                     p_location_id => asgn_table(i).location_id,
                                     p_ccid_id     => asgn_table(i).ccid,
                         p_Log_level_rec    => g_log_level_rec);

          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

              h_return_status := FND_API.G_RET_STS_ERROR;
              return(h_return_status);

          end if;

          if ((asgn_table(i).trans_units < 0) AND
                                           (asgn_table(i).dist_id is NULL)) then

--- int_debug.print('trans_units < 0 and dist_id is NULL');

              h_return_status := FND_API.G_RET_STS_ERROR;
              return(h_return_status);
          end if;

          if (asgn_table(i).units + asgn_table(i).trans_units < 0) then

--- int_debug.print('units + trans_units < 0');

              h_return_status := FND_API.G_RET_STS_ERROR;
              return(h_return_status);
          end if;

          l_total_trans_units := l_total_trans_units+asgn_table(i).trans_units;

      END LOOP;

      if (l_total_trans_units <> 0) then

--- int_debug.print('l_total_trans_units <> 0');

          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);
      end if;

--- int_debug.print('Entered get_header_info ');

      --- Get rest of information
      get_header_info(
            X_Asset_Id                   => asset_id,
            X_Book_Type_Code             => book_type_code,
            X_Transaction_Header_Id      => l_Transaction_Header_Id,
            X_Transaction_Date_Entered   => l_Transaction_Date_Entered,
            X_Max_Transaction_Date       => l_Max_Transaction_Date,
            X_Current_PC                 => l_Current_PC,
            X_Calendar_Period_Open_Date  => l_Calendar_Period_Open_Date,
            X_Calendar_Period_Close_Date => l_Calendar_Period_Close_Date,
            X_FY_Start_Date              => l_FY_Start_Date,
            X_FY_End_Date                => l_FY_End_Date,
            X_return_status              => l_return_status,
            p_Log_level_rec    => g_log_level_rec
      );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          h_return_status := FND_API.G_RET_STS_ERROR;
          return(h_return_status);
      end if;

      -- fix for 2219293
      -- set txn_type_code based on the period of asset addition
      l_book := book_type_code; -- need to copy to local var
      l_asset := asset_id;

      select count(1)
      into l_count
      from    fa_deprn_summary ds
      where   ds.book_type_code = l_book
      and     ds.asset_id     = l_asset
      and     ds.deprn_source_code = 'BOOKS'
      and     ds.period_counter = l_current_pc - 1;

      if l_count <> 0 then  -- period of addition
        l_txn_type_code := 'TRANSFER IN/VOID';
      else
        l_txn_type_code := 'TRANSFER';
      end if;

--- int_debug.print('Calling Transfer_Asset');

      FA_TRANS_API_PUB.Do_Transfer(
         -- Standard Parameters --
         p_api_version           => p_api_version,   ----1.0,
         p_init_msg_list         => p_init_msg_list, ----FND_API.G_TRUE,
         p_commit                => p_commit,        ----FND_API.G_TRUE,
         p_validation_level      => p_validation_level,
                                                 ----FND_API.G_VALID_LEVEL_FULL,
         x_return_status         => h_return_status,
         x_msg_count             => h_msg_count,
         x_msg_data              => h_msg_data,
         p_calling_fn            =>
            'fa_modify_distributions_pkg.process_transfer',
         -- API Options --
         p_debug_flag            => p_debug_flag,    ----'NO',
         -- Out Parameters --
         x_transaction_header_id => l_Transaction_Header_Id,
         -- Transaction Info --
         p_transaction_date_entered
                                 => nvl(asgn_table(1).transaction_date_entered,
                                        l_Transaction_Date_Entered),
         p_transaction_name      => NULL,
         p_mass_reference_id     => NULL,
         p_calling_interface     => 'FA_MODIFY_DISTS',
         p_last_update_date      => asgn_table(1).last_update_date,
         p_last_updated_by       => asgn_table(1).last_updated_by,
         p_created_by            => asgn_table(1).last_updated_by,
         p_creation_date         => asgn_table(1).last_update_date,
         p_last_update_login     => asgn_table(1).last_update_login,
         p_attribute1            => asgn_table(1).attribute1,
         p_attribute2            => asgn_table(1).attribute2,
         p_attribute3            => asgn_table(1).attribute3,
         p_attribute4            => asgn_table(1).attribute4,
         p_attribute5            => asgn_table(1).attribute5,
         p_attribute6            => asgn_table(1).attribute6,
         p_attribute7            => asgn_table(1).attribute7,
         p_attribute8            => asgn_table(1).attribute8,
         p_attribute9            => asgn_table(1).attribute9,
         p_attribute10           => asgn_table(1).attribute10,
         p_attribute11           => asgn_table(1).attribute11,
         p_attribute12           => asgn_table(1).attribute12,
         p_attribute13           => asgn_table(1).attribute13,
         p_attribute14           => asgn_table(1).attribute14,
         p_attribute15           => asgn_table(1).attribute15,
         p_attribute_category_code
                                 => asgn_table(1).attribute_category_code,
         -- Asset Header Info --
         p_asset_id              => asset_id,
         p_book_type_code        => book_type_code
      );

      x_return_status := h_return_status;
      x_msg_count     := h_msg_count;
      x_msg_data      := h_msg_data;

      if (h_return_status <> FND_API.G_RET_STS_SUCCESS) then
          h_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      return(h_return_status);

  EXCEPTION
      when others then
          h_return_status := FND_API.G_RET_STS_ERROR;
          x_return_status := h_return_status;
          x_msg_count     := h_msg_count;
          x_msg_data      := h_msg_data;

          return(h_return_status);
  END;

 PROCEDURE get_header_info(
            X_Asset_Id                   IN NUMBER,
            X_Book_Type_Code             IN VARCHAR2,
            X_Transaction_Header_Id      OUT NOCOPY NUMBER,
            X_Transaction_Date_Entered   OUT NOCOPY DATE,
            X_Max_Transaction_Date       OUT NOCOPY DATE,
            X_Current_PC                 OUT NOCOPY NUMBER,
            X_Calendar_Period_Open_Date  OUT NOCOPY DATE,
            X_Calendar_Period_Close_Date OUT NOCOPY DATE,
            X_FY_Start_Date              OUT NOCOPY DATE,
            X_FY_End_Date                OUT NOCOPY DATE,
            X_return_status              OUT NOCOPY VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  Lv_Fiscal_Year      Number(4);
  Lv_Fiscal_Year_Name Varchar2(30);

  BEGIN

      -------------------------------------------------
      select fa_transaction_headers_s.nextval
      into   X_Transaction_Header_Id
      from   sys.dual;
      -------------------------------------------------
      select greatest(calendar_period_open_date,
             least(sysdate, calendar_period_close_date)),
             calendar_period_open_date,
             calendar_period_close_date,
             period_counter
      into   X_Transaction_Date_Entered,
             X_Calendar_Period_Open_Date,
             X_Calendar_Period_Close_Date,
             X_Current_PC
      from   fa_deprn_periods
      where  book_type_code = X_Book_Type_Code
      and    period_close_date is null;
      -------------------------------------------------
      select fiscal_year_name, current_fiscal_year
      into   lv_fiscal_year_name, lv_fiscal_year
      from   fa_book_controls
      where  book_type_code = X_Book_Type_Code;
      -------------------------------------------------
      select start_date, end_date
      into   X_FY_Start_Date, X_FY_End_Date
      from   fa_fiscal_year
      where  fiscal_year = lv_fiscal_year
      and    fiscal_year_name = lv_fiscal_year_name;
      -------------------------------------------------
      select max(transaction_date_entered)
      into   X_Max_Transaction_Date
      from   fa_transaction_headers
      where  asset_id = X_Asset_Id
      and    book_type_code = X_Book_Type_Code;
      -------------------------------------------------

      X_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    when others then
          X_return_status := FND_API.G_RET_STS_ERROR;

  END get_header_info;

  FUNCTION check_if_corp_book(
        book_type_code IN VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2
  IS

    X_corp_book_type_code VARCHAR2(30) := NULL;

    CURSOR Chk_Book_Class_C IS
        SELECT count(*)
        FROM   fa_book_controls BC
        WHERE  BC.book_type_code = X_corp_book_type_code
        AND    BC.book_class = 'CORPORATE'
        AND    rownum <= 1;

    l_book_class     NUMBER       := 0;
    l_return_status  VARCHAR2(15) := FND_API.G_RET_STS_ERROR;
    l_cbc_c_open     BOOLEAN      := FALSE;

  BEGIN

      if book_type_code is NOT NULL then

           l_book_class := 0;
           X_corp_book_type_code := book_type_code;

           OPEN  Chk_Book_Class_C;

           FETCH Chk_Book_Class_C
           INTO  l_book_class;

           if (Chk_Book_Class_C%NOTFOUND) then

             CLOSE Chk_Book_Class_C;

             l_return_status := FND_API.G_RET_STS_ERROR;
             return(l_return_status);

           end if;

           CLOSE Chk_Book_Class_C;


           if (l_book_class = 1) then
               l_return_status := FND_API.G_RET_STS_SUCCESS;
               return(l_return_status);
           else
               l_return_status := FND_API.G_RET_STS_ERROR;
               return(l_return_status);
           end if;

      else
           l_return_status := FND_API.G_RET_STS_ERROR;
           return(l_return_status);
      end if;

  EXCEPTION

      when others then

          if (l_cbc_c_open = TRUE) then
              CLOSE Chk_Book_Class_C;
              l_cbc_c_open := FALSE;
          end if;

          l_return_status := FND_API.G_RET_STS_ERROR;
          return(l_return_status);


  END check_if_corp_book;

  FUNCTION check_location_ccid(
        p_location_id IN NUMBER,
        p_ccid_id IN NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2
  IS

    X_location_id NUMBER := NULL;
    X_ccid_id     NUMBER := NULL;

    CURSOR Chk_Location_C IS
        SELECT count(*)
        FROM   fa_locations loc
        WHERE  loc.location_id = NVL(X_location_id, -1)
        AND    loc.enabled_flag = 'Y'
        AND    rownum <= 1;

    CURSOR validate_ccid IS
        SELECT  count(*)
        FROM    gl_code_combinations glcc
        WHERE   glcc.code_combination_id = NVL(X_ccid_id, -1)
        AND     glcc.enabled_flag = 'Y'
        AND     nvl(glcc.end_date_active, sysdate) >= sysdate
        AND     rownum <= 1;

    l_loc_out       NUMBER       := 0;
    l_ccid_out      NUMBER       := 0;
    l_return_status VARCHAR2(15) := FND_API.G_RET_STS_ERROR;
    l_cl_c_open     BOOLEAN      := FALSE;
    l_cc_c_open     BOOLEAN      := FALSE;


    CURSOR Chk_Ccid_C IS
        SELECT  count(*)
        FROM    gl_code_combinations glcc
        WHERE   glcc.code_combination_id = NVL(X_ccid_id, -1)
        AND     glcc.enabled_flag = 'Y'
        AND     nvl(glcc.end_date_active, sysdate) >= sysdate
        AND     rownum <= 1;

  BEGIN

       l_loc_out     := 0;
       X_location_id := p_location_id;

       OPEN  Chk_Location_C;
       FETCH Chk_Location_C INTO l_loc_out;

       if (Chk_Location_C%NOTFOUND) then
           l_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       CLOSE Chk_Location_C;
       l_cl_c_open := TRUE;

       if (l_loc_out = 1) then
           l_return_status := FND_API.G_RET_STS_SUCCESS;
       else
           l_return_status := FND_API.G_RET_STS_ERROR;
           return(l_return_status);
       end if;

       l_ccid_out    := 0;
       X_ccid_id     := p_ccid_id;

       OPEN  Chk_Ccid_C;
       FETCH Chk_Ccid_C INTO l_ccid_out;

       if (Chk_Ccid_C%NOTFOUND) then
           l_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       CLOSE Chk_Ccid_C;
       l_cc_c_open := TRUE;

       if (l_ccid_out = 1) then
           l_return_status := FND_API.G_RET_STS_SUCCESS;
           return(l_return_status);
       else
           l_return_status := FND_API.G_RET_STS_ERROR;
           return(l_return_status);
       end if;

  EXCEPTION

      when others then

          if (l_cl_c_open = TRUE) then
              CLOSE Chk_Location_C;
              l_cl_c_open := FALSE;
          end if;

          if (l_cc_c_open = TRUE) then
              CLOSE Chk_Ccid_C;
              l_cc_c_open := FALSE;
          end if;

          l_return_status := FND_API.G_RET_STS_ERROR;
          return(l_return_status);


  END check_location_ccid;


END FA_MODIFY_DISTRIBUTIONS_PKG;

/
