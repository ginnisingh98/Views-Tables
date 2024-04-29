--------------------------------------------------------
--  DDL for Package FA_MODIFY_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MODIFY_DISTRIBUTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: FAMDSTS.pls 120.3.12010000.2 2009/07/19 14:36:01 glchen ship $ */

-- GLOBAL VARIABLES

-- asgn_line_rec  : Record to store one distribution

TYPE  asgn_line_rec IS RECORD
(   row_id                   ROWID,
    dist_id                  NUMBER(15),
    asset_id                 NUMBER(15) DEFAULT NULL,
    units                    NUMBER,     -- units assigned
    transaction_date_entered DATE,
    date_effective           DATE,
    ccid                     NUMBER(15),
    location_id              NUMBER(15),
    th_id_in                 NUMBER(15),
    assigned_to              NUMBER(15),
    trans_units              NUMBER,
    record_status            VARCHAR2(6),
    -- record_status = 'UPDATE', 'INSERT' or 'DELETE'.  Informs what
    -- SQL transaction has to be performed on this distribution line
    -- (non-database field, added for Transfer transaction.)
    attribute1               VARCHAR2(150),
    attribute2               VARCHAR2(150),
    attribute3               VARCHAR2(150),
    attribute4               VARCHAR2(150),
    attribute5               VARCHAR2(150),
    attribute6               VARCHAR2(150),
    attribute7               VARCHAR2(150),
    attribute8               VARCHAR2(150),
    attribute9               VARCHAR2(150),
    attribute10              VARCHAR2(150),
    attribute11              VARCHAR2(150),
    attribute12              VARCHAR2(150),
    attribute13              VARCHAR2(150),
    attribute14              VARCHAR2(150),
    attribute15              VARCHAR2(150),
    attribute_category_code  VARCHAR2(30),
    last_updated_by          NUMBER(15),
    last_update_date         DATE,
    last_update_login        NUMBER(15)
);

-- asgn_line_tbl  : A global table to store distribution lines

TYPE asgn_line_tbl IS TABLE OF asgn_line_rec
 INDEX BY BINARY_INTEGER;

asgn_table      asgn_line_tbl;

-- Global variable holding the number of asgn lines count
g_asgn_count        NUMBER  := 0;

--
-- Procedure    load_asgn_table
--
--       Usage  Called by client to load all distributions in the
--      global table asgn_line_tbl before calling the API
--
--

PROCEDURE load_asgn_table (
        p_row_id                   IN ROWID  default null,
        p_dist_id                  IN NUMBER default null,
        p_asset_id                 IN NUMBER default null,
        p_units                    IN NUMBER,
        p_transaction_date_entered IN DATE,
        p_date_effective           IN DATE,
        p_ccid                     IN NUMBER,
        p_location_id              IN NUMBER,
        p_th_id_in                 IN NUMBER,
        p_assigned_to              IN NUMBER,
        p_trans_units              IN NUMBER,
        p_record_status            IN VARCHAR2,
        p_attribute1               IN VARCHAR2,
        p_attribute2               IN VARCHAR2,
        p_attribute3               IN VARCHAR2,
        p_attribute4               IN VARCHAR2,
        p_attribute5               IN VARCHAR2,
        p_attribute6               IN VARCHAR2,
        p_attribute7               IN VARCHAR2,
        p_attribute8               IN VARCHAR2,
        p_attribute9               IN VARCHAR2,
        p_attribute10              IN VARCHAR2,
        p_attribute11              IN VARCHAR2,
        p_attribute12              IN VARCHAR2,
        p_attribute13              IN VARCHAR2,
        p_attribute14              IN VARCHAR2,
        p_attribute15              IN VARCHAR2,
        p_attribute_category_code  IN VARCHAR2,
        p_last_updated_by          IN NUMBER,
        p_last_update_date         IN DATE,
        p_last_update_login        IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE modify_distributions(
        P_api_version      IN  NUMBER,
        P_init_msg_list    IN  VARCHAR2,
        P_commit           IN  VARCHAR2,
        P_validation_level IN  NUMBER,
        P_debug_flag       IN  VARCHAR2,
        X_return_status    OUT NOCOPY VARCHAR2,
        X_msg_count        OUT NOCOPY NUMBER,
        X_msg_data         OUT NOCOPY VARCHAR2);

  PROCEDURE insert_dist_table(
        row_id                   IN  ROWID,
        asset_id                 IN  NUMBER,
        transfer_units           IN  NUMBER,
        transaction_date_entered IN  DATE,
        from_dist_id             IN  NUMBER,
        from_location_id         IN  NUMBER,
        from_assigned_to         IN  NUMBER,
        from_ccid                IN  NUMBER,
        to_dist_id               IN  NUMBER,
        to_location_id           IN  NUMBER,
        to_assigned_to           IN  NUMBER,
        to_ccid                  IN  NUMBER,
        attribute1               IN  VARCHAR2,
        attribute2               IN  VARCHAR2,
        attribute3               IN  VARCHAR2,
        attribute4               IN  VARCHAR2,
        attribute5               IN  VARCHAR2,
        attribute6               IN  VARCHAR2,
        attribute7               IN  VARCHAR2,
        attribute8               IN  VARCHAR2,
        attribute9               IN  VARCHAR2,
        attribute10              IN  VARCHAR2,
        attribute11              IN  VARCHAR2,
        attribute12              IN  VARCHAR2,
        attribute13              IN  VARCHAR2,
        attribute14              IN  VARCHAR2,
        attribute15              IN  VARCHAR2,
        attribute_category_code  IN  VARCHAR2,
        post_batch_id            IN  NUMBER,
        last_updated_by          IN  NUMBER,
        last_update_date         IN  DATE,
        last_update_login        IN  NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  FUNCTION process_unit_adjustment(
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        p_commit           IN  VARCHAR2,
        p_validation_level IN  NUMBER,
        p_debug_flag       IN  VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        book_type_code     IN  VARCHAR2,
        asset_id           IN  NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2;

  FUNCTION process_transfer(
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        p_commit           IN  VARCHAR2,
        p_validation_level IN  NUMBER,
        p_debug_flag       IN  VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        book_type_code     IN  VARCHAR2,
        asset_id           IN  NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2;


 PROCEDURE get_header_info(
            X_Asset_Id                   IN  NUMBER,
            X_Book_Type_Code             IN  VARCHAR2,
            X_Transaction_Header_Id      OUT NOCOPY NUMBER,
            X_Transaction_Date_Entered   OUT NOCOPY DATE,
            X_Max_Transaction_Date       OUT NOCOPY DATE,
            X_Current_PC                 OUT NOCOPY NUMBER,
            X_Calendar_Period_Open_Date  OUT NOCOPY DATE,
            X_Calendar_Period_Close_Date OUT NOCOPY DATE,
            X_FY_Start_Date              OUT NOCOPY DATE,
            X_FY_End_Date                OUT NOCOPY DATE,
            X_return_status              OUT NOCOPY VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


  FUNCTION check_if_corp_book(
        book_type_code IN VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2;

  FUNCTION check_location_ccid(
        p_location_id IN NUMBER,
        p_ccid_id     IN NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN VARCHAR2;


END FA_MODIFY_DISTRIBUTIONS_PKG;

/
