--------------------------------------------------------
--  DDL for Package PN_RECOVERY_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_RECOVERY_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRCEXTS.pls 115.8 2003/06/13 02:07:46 ftanudja noship $ */

TYPE date_table_type       IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE number_table_type     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE extract_line_expense_area(
            errbuf               OUT NOCOPY VARCHAR2,
            retcode              OUT NOCOPY VARCHAR2,
            p_location_code      IN pn_locations.location_code%TYPE,
            p_property_code      IN pn_properties.property_code%TYPE,
            p_as_of_date         IN VARCHAR2,
            p_from_date          IN VARCHAR2,
            p_to_date            IN VARCHAR2,
            p_currency_code      IN pn_rec_exp_line.currency_code%TYPE DEFAULT NULL,
            p_pop_exp_class_dtl  IN VARCHAR2,
            p_pop_area_class_dtl IN VARCHAR2,
            p_keep_override      IN VARCHAR2,
            p_extract_code       IN pn_rec_exp_line.expense_extract_code%TYPE,
            p_called_from        IN VARCHAR2 DEFAULT 'SRS');

PROCEDURE extract_expense(
            errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
            p_expense_class_id      IN pn_rec_expcl.expense_class_id%TYPE,
            p_as_of_date            IN VARCHAR2,
            p_from_date             IN VARCHAR2,
            p_to_date               IN VARCHAR2,
            p_expense_line_id       IN pn_rec_exp_line.expense_line_id%TYPE,
            p_keep_override         IN VARCHAR2);

PROCEDURE extract_area(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY VARCHAR2,
            p_area_class_id    IN pn_rec_arcl.area_class_id%TYPE,
            p_as_of_date       IN VARCHAR2,
            p_from_date        IN VARCHAR2,
            p_to_date          IN VARCHAR2,
            p_keep_override    IN VARCHAR2);

PROCEDURE purge_expense_lines_itf_data(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY VARCHAR2,
            p_extract_code     IN pn_rec_exp_line.expense_extract_code%TYPE DEFAULT NULL,
            p_location_code    IN pn_locations.location_code%TYPE                DEFAULT NULL,
            p_property_code    IN pn_properties.property_code%TYPE               DEFAULT NULL,
            p_from_date        IN VARCHAR2                                       DEFAULT NULL,
            p_to_date          IN VARCHAR2                                       DEFAULT NULL,
            p_transfer_flag    IN pn_rec_exp_itf.transfer_flag%TYPE              DEFAULT NULL,
            p_delete_all_flag  IN VARCHAR2                                       DEFAULT 'N');

PROCEDURE process_vacancy(p_start_date   DATE,
                          p_end_date     DATE,
                          p_area         NUMBER,
                          p_date_table   IN OUT NOCOPY date_table_type,
                          p_number_table IN OUT NOCOPY number_table_type,
                          p_add          BOOLEAN);

END pn_recovery_extract_pkg;

 

/
