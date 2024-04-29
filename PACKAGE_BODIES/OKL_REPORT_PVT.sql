--------------------------------------------------------
--  DDL for Package Body OKL_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REPORT_PVT" AS
/* $Header: OKLCREPB.pls 120.14 2008/03/11 09:55:16 schodava noship $ */

PROCEDURE ADD_LANGUAGE IS
BEGIN
	Okl_Rep_Pvt.add_language;
END ;

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_rec,
		x_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report;

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type
 ) IS
	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_rec,
		x_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report;

 PROCEDURE delete_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type
 ) IS
	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report;

 PROCEDURE submit_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_id				IN NUMBER
 ) IS
	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'SUBMIT_REPORT';
	l_repv_rec	repv_rec_type;
	x_repv_rec	repv_rec_type;

	CURSOR c_get_details(p_rep_id NUMBER) IS
	   SELECT	REPORT_ID
			,NAME
			,CHART_OF_ACCOUNTS_ID
			,BOOK_CLASSIFICATION_CODE
			,LEDGER_ID
			,REPORT_CATEGORY_CODE
			,REPORT_TYPE_CODE
			,ACTIVITY_CODE
			,STATUS_CODE
			,DESCRIPTION
			,EFFECTIVE_FROM_DATE
			,EFFECTIVE_TO_DATE
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,LANGUAGE
			,SOURCE_LANG
			,SFWT_FLAG
	   FROM	OKL_REPORTS_V
	   WHERE REPORT_ID = p_rep_id;

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	OPEN c_get_details(p_rep_id);
		FETCH c_get_details
			INTO l_repv_rec.report_id
				,l_repv_rec.name
				,l_repv_rec.chart_of_accounts_id
				,l_repv_rec.book_classification_code
				,l_repv_rec.ledger_id
				,l_repv_rec.report_category_code
				,l_repv_rec.report_type_code
				,l_repv_rec.activity_code
				,l_repv_rec.status_code
				,l_repv_rec.description
				,l_repv_rec.effective_from_date
				,l_repv_rec.effective_to_date
				,l_repv_rec.created_by
				,l_repv_rec.creation_date
				,l_repv_rec.last_updated_by
				,l_repv_rec.last_update_date
				,l_repv_rec.last_update_login
				,l_repv_rec.language
				,l_repv_rec.source_lang
				,l_repv_rec.sfwt_flag;
	CLOSE c_get_details;

	-- Tapi Call
	Okl_Rep_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		l_repv_rec,
		x_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END submit_report;

 PROCEDURE activate_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_id				IN NUMBER
 ) IS
	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'ACTIVATE_REPORT';
	l_repv_rec	repv_rec_type;
	x_repv_rec	repv_rec_type;

	CURSOR c_get_details(p_rep_id NUMBER) IS
	   SELECT	REPORT_ID
			,NAME
			,CHART_OF_ACCOUNTS_ID
			,BOOK_CLASSIFICATION_CODE
			,LEDGER_ID
			,REPORT_CATEGORY_CODE
			,REPORT_TYPE_CODE
			,ACTIVITY_CODE
			,STATUS_CODE
			,DESCRIPTION
			,EFFECTIVE_FROM_DATE
			,EFFECTIVE_TO_DATE
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,LANGUAGE
			,SOURCE_LANG
			,SFWT_FLAG
	   FROM	OKL_REPORTS_V
	   WHERE REPORT_ID = p_rep_id;

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	OPEN c_get_details(p_rep_id);
		FETCH c_get_details
			INTO l_repv_rec.report_id
				,l_repv_rec.name
				,l_repv_rec.chart_of_accounts_id
				,l_repv_rec.book_classification_code
				,l_repv_rec.ledger_id
				,l_repv_rec.report_category_code
				,l_repv_rec.report_type_code
				,l_repv_rec.activity_code
				,l_repv_rec.status_code
				,l_repv_rec.description
				,l_repv_rec.effective_from_date
				,l_repv_rec.effective_to_date
				,l_repv_rec.created_by
				,l_repv_rec.creation_date
				,l_repv_rec.last_updated_by
				,l_repv_rec.last_update_date
				,l_repv_rec.last_update_login
				,l_repv_rec.language
				,l_repv_rec.source_lang
				,l_repv_rec.sfwt_flag;
	CLOSE c_get_details;

	l_repv_rec.status_code	:=	'ACTIVE';

	-- Tapi Call
	Okl_Rep_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		l_repv_rec,
		x_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END activate_report;

 PROCEDURE lock_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type
 ) IS
	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report;

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type,
    x_repv_tbl			OUT NOCOPY repv_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_tbl,
		x_repv_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report;

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type,
    x_repv_tbl			OUT NOCOPY repv_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_tbl,
		x_repv_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report;

 PROCEDURE delete_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report;

 PROCEDURE lock_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rep_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report;

 PROCEDURE create_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type,
    x_rpp_rec			OUT NOCOPY rpp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_rec,
		x_rpp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_parameters;

 PROCEDURE update_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type,
    x_rpp_rec			OUT NOCOPY rpp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_rec,
		x_rpp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_parameters;

 PROCEDURE delete_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_parameters;

 PROCEDURE lock_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_parameters;

 PROCEDURE create_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_tbl,
		x_rpp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_parameters;

 PROCEDURE update_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_tbl,
		x_rpp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_parameters;

 PROCEDURE delete_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_parameters;

 PROCEDURE lock_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_PARAMETERS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rpp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rpp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_parameters;

 PROCEDURE create_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type,
    x_rap_rec			OUT NOCOPY rap_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_rec,
		x_rap_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_acc_parameters;

 PROCEDURE update_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type,
    x_rap_rec			OUT NOCOPY rap_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_rec,
		x_rap_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_acc_parameters;

 PROCEDURE delete_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_acc_parameters;

 PROCEDURE lock_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_acc_parameters;

 PROCEDURE create_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_tbl,
		x_rap_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_acc_parameters;

 PROCEDURE update_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_tbl,
		x_rap_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_acc_parameters;

 PROCEDURE delete_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_acc_parameters;

 PROCEDURE lock_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_ACC_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rap_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rap_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_acc_parameters;

 PROCEDURE create_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type,
    x_rps_rec			OUT NOCOPY rps_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_rec,
		x_rps_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_strm_parameters;

 PROCEDURE update_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type,
    x_rps_rec			OUT NOCOPY rps_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_rec,
		x_rps_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_strm_parameters;

 PROCEDURE delete_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_strm_parameters;

 PROCEDURE lock_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_strm_parameters;

 PROCEDURE create_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_tbl,
		x_rps_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_strm_parameters;

 PROCEDURE update_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_tbl,
		x_rps_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_strm_parameters;

 PROCEDURE delete_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_strm_parameters;

 PROCEDURE lock_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_STRM_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rsp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rps_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_strm_parameters;

 PROCEDURE create_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type,
    x_rtp_rec			OUT NOCOPY rtp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_rec,
		x_rtp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_trx_parameters;

 PROCEDURE update_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type,
    x_rtp_rec			OUT NOCOPY rtp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_rec,
		x_rtp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_trx_parameters;

 PROCEDURE delete_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_trx_parameters;

 PROCEDURE lock_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_rec);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_trx_parameters;

 PROCEDURE create_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.insert_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_tbl,
		x_rtp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report_trx_parameters;

 PROCEDURE update_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.update_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_tbl,
		x_rtp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report_trx_parameters;

 PROCEDURE delete_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'DELETE_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.delete_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END delete_report_trx_parameters;

 PROCEDURE lock_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'LOCK_REPORT_TRX_PARAMS';

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Tapi Call
	Okl_Rtp_Pvt.lock_row(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_rtp_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSE
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
			l_return_status := x_return_status;
		END IF;
 	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END lock_report_trx_parameters;

 FUNCTION validate_accounts(
			p_rap_tbl	rap_tbl_type
			,p_coa_id OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE) RETURN BOOLEAN IS

	l_return_status	boolean	:= true;
	l_test_value	 fnd_flex_values_vl.flex_value%TYPE;
	i	NUMBER	:=	0;

	CURSOR c_is_valid_nat_acc(
			p_coa_id OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE
			,p_segment_id OKL_REPORT_ACC_PARAMS.SEGMENT_RANGE_FROM%TYPE) IS
		SELECT	flex.flex_value Account_Number
		FROM		fnd_id_flex_segments s,
				fnd_segment_attribute_values sav,
				fnd_flex_values_vl flex
		WHERE	s.application_id = 101 -- GL Application ID
			  AND s.id_flex_code = 'GL#'
			  AND s.enabled_flag = 'Y'
			  AND s.application_column_name = sav.application_column_name
			  AND sav.application_id = 101
			  AND sav.id_flex_code = 'GL#'
			  AND sav.id_flex_num = s.id_flex_num
			  AND sav.attribute_value = 'Y'
			  AND sav.segment_attribute_type = 'GL_ACCOUNT'
			  AND s.flex_value_set_id = flex.flex_value_set_id
			  AND s.id_flex_num = p_coa_id
			  AND flex.flex_value_id = p_segment_id;

 BEGIN
	IF (p_rap_tbl.COUNT <= 0) THEN
	   OKL_API.set_message(p_app_name      => G_APP_NAME,
					p_msg_name      => 'OKL_RPP_ONE_NAT_ACC_MIN');
	   l_return_status	 :=	false;
	END IF;

	IF (p_rap_tbl.COUNT > 0) THEN
		FOR i IN p_rap_tbl.FIRST..p_rap_tbl.LAST LOOP

		   OPEN c_is_valid_nat_acc(p_coa_id, p_rap_tbl(i).segment_range_from);
			FETCH c_is_valid_nat_acc INTO l_test_value;

			IF (c_is_valid_nat_acc%NOTFOUND) THEN
			   OKL_API.set_message(p_app_name      => G_APP_NAME,
							p_msg_name      => 'OKL_RECON_COA_ACC_MISMATCH');
			   l_return_status	 :=	false;
			   CLOSE c_is_valid_nat_acc;
			   return l_return_status;
			END IF;
		   CLOSE c_is_valid_nat_acc;

		   OPEN c_is_valid_nat_acc(p_coa_id, p_rap_tbl(i).segment_range_to);
			FETCH c_is_valid_nat_acc INTO l_test_value;

			IF (c_is_valid_nat_acc%NOTFOUND) THEN
			   OKL_API.set_message(p_app_name      => G_APP_NAME,
							p_msg_name      => 'OKL_RECON_COA_ACC_MISMATCH');
			   l_return_status	 :=	false;
			   CLOSE c_is_valid_nat_acc;
			   return l_return_status;
			END IF;
		   CLOSE c_is_valid_nat_acc;

		END LOOP;
	END IF;
	return l_return_status;
 END;

 FUNCTION validate_transactions(
			p_rtp_tbl	rtp_tbl_type) RETURN BOOLEAN IS

	l_return_status	boolean	:= true;
	l_test_value	 NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN
	IF (p_rtp_tbl.COUNT <= 0) THEN
	   OKL_API.set_message(p_app_name      => G_APP_NAME,
					p_msg_name      => 'OKL_RPP_ONE_TRY_ID_MIN');
	   l_return_status	 :=	false;
	END IF;
	return l_return_status;
 END;

 FUNCTION validate_streams(
			p_rps_tbl	rps_tbl_type) RETURN BOOLEAN IS

	l_return_status	boolean	:= true;
	l_test_value	 NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN
	IF (p_rps_tbl.COUNT <= 0) THEN
	   OKL_API.set_message(p_app_name      => G_APP_NAME,
					p_msg_name      => 'OKL_RPP_ONE_STY_ID_MIN');
	   l_return_status	 :=	false;
	END IF;
	return l_return_status;
 END;

 PROCEDURE ident_rpp_tbl(
			p_rpp_tbl	IN rpp_tbl_type,
			x_crt_rpp_tbl	OUT NOCOPY rpp_tbl_type,
			x_upd_rpp_tbl	OUT NOCOPY rpp_tbl_type,
			x_del_rpp_tbl	OUT NOCOPY rpp_tbl_type) IS

	CURSOR c_is_record_exists(p_param_id	OKL_REPORT_PARAMETERS.PARAMETER_ID%TYPE) IS
	   SELECT 1
	   FROM OKL_REPORT_PARAMETERS
	   WHERE PARAMETER_ID = p_param_id;

	i	NUMBER	:=	0;
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	del_idx	NUMBER	:=	0;
	l_test_value	 NUMBER	:=	0;
	l_vld_value	boolean	:=	true;

 BEGIN

	FOR i IN p_rpp_tbl.FIRST..p_rpp_tbl.LAST LOOP
		IF ((p_rpp_tbl(i).parameter_id IS NULL OR p_rpp_tbl(i).parameter_id = OKL_API.G_MISS_NUM)
			AND (p_rpp_tbl(i).param_num_value1 IS NOT NULL OR p_rpp_tbl(i).param_char_value1 IS NOT NULL))THEN
		   x_crt_rpp_tbl(crt_idx)	:=	p_rpp_tbl(i);
		   crt_idx	:=	crt_idx	+	1;
		ELSE
		   IF (p_rpp_tbl(i).parameter_type IN ('OPERATING_UNIT','LEGAL_ENTITY') AND
				p_rpp_tbl(i).parameter_id IS NOT NULL AND
				(p_rpp_tbl(i).param_num_value1 IS NULL OR p_rpp_tbl(i).param_num_value1 = OKL_API.G_MISS_NUM)) THEN

			OPEN c_is_record_exists(p_rpp_tbl(i).parameter_id);

				FETCH c_is_record_exists INTO l_test_value;

				IF (c_is_record_exists%FOUND) THEN
					x_del_rpp_tbl(del_idx)	:=	p_rpp_tbl(i);
					del_idx	:=	del_idx	+	1;
				END IF;
			CLOSE c_is_record_exists;
		   ELSIF (p_rpp_tbl(i).parameter_id IS NOT NULL AND
				(p_rpp_tbl(i).param_num_value1 IS NOT NULL OR
				p_rpp_tbl(i).param_char_value1 IS NOT NULL)) THEN
			OPEN c_is_record_exists(p_rpp_tbl(i).parameter_id);

				FETCH c_is_record_exists INTO l_test_value;

				IF (c_is_record_exists%FOUND) THEN
					x_upd_rpp_tbl(upd_idx)	:=	p_rpp_tbl(i);
					upd_idx	:=	upd_idx	+	1;
				ELSE
					x_crt_rpp_tbl(crt_idx)	:=	p_rpp_tbl(i);
					crt_idx	:=	crt_idx	+	1;
				END IF;
			CLOSE c_is_record_exists;
		   END IF;
		END IF;
	END LOOP;

 END ident_rpp_tbl;

 PROCEDURE ident_rap_tbl(
			p_rap_tbl	IN rap_tbl_type,
			x_crt_rap_tbl	OUT NOCOPY rap_tbl_type,
			x_upd_rap_tbl	OUT NOCOPY rap_tbl_type) IS

	CURSOR c_is_record_exists(p_acc_param_id	OKL_REPORT_ACC_PARAMS.ACC_PARAMETER_ID%TYPE) IS
	   SELECT 1
	   FROM OKL_REPORT_ACC_PARAMS
	   WHERE ACC_PARAMETER_ID = p_acc_param_id;

	i	NUMBER	:=	0;
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	l_test_value	 NUMBER	:=	0;
	l_vld_value	boolean	:=	true;

 BEGIN

	FOR i IN p_rap_tbl.FIRST..p_rap_tbl.LAST LOOP
		IF (p_rap_tbl(i).acc_parameter_id IS NULL OR p_rap_tbl(i).acc_parameter_id = OKL_API.G_MISS_NUM) THEN
		   x_crt_rap_tbl(crt_idx)	:=	p_rap_tbl(i);
		   crt_idx	:=	crt_idx	+	1;
		ELSE
		   IF (p_rap_tbl(i).acc_parameter_id IS NOT NULL) THEN

			OPEN c_is_record_exists(p_rap_tbl(i).acc_parameter_id);

				FETCH c_is_record_exists INTO l_test_value;

				IF (c_is_record_exists%FOUND) THEN
					x_upd_rap_tbl(upd_idx)	:=	p_rap_tbl(i);
					upd_idx	:=	upd_idx	+	1;
				ELSE
					x_crt_rap_tbl(crt_idx)	:=	p_rap_tbl(i);
					crt_idx	:=	crt_idx	+	1;
				END IF;
			CLOSE c_is_record_exists;
		    END IF;
		END IF;
	END LOOP;

 END ident_rap_tbl;

 PROCEDURE ident_rps_tbl(
			p_rps_tbl	IN rps_tbl_type,
			x_crt_rps_tbl	OUT NOCOPY rps_tbl_type,
			x_upd_rps_tbl	OUT NOCOPY rps_tbl_type) IS

	CURSOR c_is_record_exists(p_strm_param_id	OKL_REPORT_STREAM_PARAMS.STREAM_PARAMETER_ID%TYPE) IS
	   SELECT 1
	   FROM OKL_REPORT_STREAM_PARAMS
	   WHERE STREAM_PARAMETER_ID = p_strm_param_id;

	i	NUMBER	:=	0;
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	l_test_value	 NUMBER	:=	0;
	l_vld_value	boolean	:=	true;

 BEGIN

	FOR i IN p_rps_tbl.FIRST..p_rps_tbl.LAST LOOP
		IF (p_rps_tbl(i).stream_parameter_id IS NULL OR p_rps_tbl(i).stream_parameter_id = OKL_API.G_MISS_NUM) THEN
		   x_crt_rps_tbl(crt_idx)	:=	p_rps_tbl(i);
		   crt_idx	:=	crt_idx	+	1;
		ELSE
		   IF (p_rps_tbl(i).stream_parameter_id IS NOT NULL) THEN

			OPEN c_is_record_exists(p_rps_tbl(i).stream_parameter_id);

				FETCH c_is_record_exists INTO l_test_value;

				IF (c_is_record_exists%FOUND) THEN
					x_upd_rps_tbl(upd_idx)	:=	p_rps_tbl(i);
					upd_idx	:=	upd_idx	+	1;
				ELSE
					x_crt_rps_tbl(crt_idx)	:=	p_rps_tbl(i);
					crt_idx	:=	crt_idx	+	1;
				END IF;
			CLOSE c_is_record_exists;
		    END IF;
		END IF;
	END LOOP;

 END ident_rps_tbl;

 PROCEDURE ident_rtp_tbl(
			p_rtp_tbl	IN rtp_tbl_type,
			x_crt_rtp_tbl	OUT NOCOPY rtp_tbl_type,
			x_upd_rtp_tbl	OUT NOCOPY rtp_tbl_type) IS

	CURSOR c_is_record_exists(p_trx_param_id	OKL_REPORT_TRX_PARAMS.TRX_PARAMETER_ID%TYPE) IS
	   SELECT 1
	   FROM OKL_REPORT_TRX_PARAMS
	   WHERE TRX_PARAMETER_ID = p_trx_param_id;

	i	NUMBER	:=	0;
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	l_test_value	 NUMBER	:=	0;
	l_vld_value	boolean	:=	true;

 BEGIN

	FOR i IN p_rtp_tbl.FIRST..p_rtp_tbl.LAST LOOP
		IF ((p_rtp_tbl(i).trx_parameter_id IS NULL OR p_rtp_tbl(i).trx_parameter_id = OKL_API.G_MISS_NUM)
			AND p_rtp_tbl(i).try_id IS NOT NULL )THEN
		   x_crt_rtp_tbl(crt_idx)	:=	p_rtp_tbl(i);
		   crt_idx	:=	crt_idx	+	1;
		ELSE
		   IF (p_rtp_tbl(i).trx_parameter_id IS NOT NULL
			AND p_rtp_tbl(i).try_id IS NOT NULL) THEN

			OPEN c_is_record_exists(p_rtp_tbl(i).trx_parameter_id);

				FETCH c_is_record_exists INTO l_test_value;

				IF (c_is_record_exists%FOUND) THEN
					x_upd_rtp_tbl(upd_idx)	:=	p_rtp_tbl(i);
					upd_idx	:=	upd_idx	+	1;
				ELSE
					x_crt_rtp_tbl(crt_idx)	:=	p_rtp_tbl(i);
					crt_idx	:=	crt_idx	+	1;
				END IF;
			CLOSE c_is_record_exists;
		    END IF;
		END IF;
	END LOOP;

 END ident_rtp_tbl;

 PROCEDURE merge_x_rpp_tbl(
	p_crt_rpp_tbl	IN rpp_tbl_type,
	p_upd_rpp_tbl	IN rpp_tbl_type,
	x_rpp_tbl	OUT NOCOPY rpp_tbl_type
 ) IS
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN

	IF (p_crt_rpp_tbl.COUNT > 0) THEN
		FOR crt_idx IN p_crt_rpp_tbl.FIRST..p_crt_rpp_tbl.LAST LOOP
		   x_rpp_tbl(i)	:=	p_crt_rpp_tbl(crt_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

	IF (p_upd_rpp_tbl.COUNT > 0) THEN
		FOR upd_idx IN p_upd_rpp_tbl.FIRST..p_upd_rpp_tbl.LAST LOOP
		   x_rpp_tbl(i)	:=	p_upd_rpp_tbl(upd_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

 END merge_x_rpp_tbl;

 PROCEDURE merge_x_rap_tbl(
	p_crt_rap_tbl	IN rap_tbl_type,
	p_upd_rap_tbl	IN rap_tbl_type,
	x_rap_tbl	OUT NOCOPY rap_tbl_type
 ) IS
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN

	IF (p_crt_rap_tbl.COUNT > 0) THEN
		FOR crt_idx IN p_crt_rap_tbl.FIRST..p_crt_rap_tbl.LAST LOOP
		   x_rap_tbl(i)	:=	p_crt_rap_tbl(crt_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

	IF (p_upd_rap_tbl.COUNT > 0) THEN
		FOR upd_idx IN p_upd_rap_tbl.FIRST..p_upd_rap_tbl.LAST LOOP
		   x_rap_tbl(i)	:=	p_upd_rap_tbl(upd_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

 END merge_x_rap_tbl;

 PROCEDURE merge_x_rps_tbl(
	p_crt_rps_tbl	IN rps_tbl_type,
	p_upd_rps_tbl	IN rps_tbl_type,
	x_rps_tbl	OUT NOCOPY rps_tbl_type
 ) IS
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN

	IF (p_crt_rps_tbl.COUNT > 0) THEN
		FOR crt_idx IN p_crt_rps_tbl.FIRST..p_crt_rps_tbl.LAST LOOP
		   x_rps_tbl(i)	:=	p_crt_rps_tbl(crt_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

	IF (p_upd_rps_tbl.COUNT > 0) THEN
		FOR upd_idx IN p_upd_rps_tbl.FIRST..p_upd_rps_tbl.LAST LOOP
		   x_rps_tbl(i)	:=	p_upd_rps_tbl(upd_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

 END merge_x_rps_tbl;

PROCEDURE merge_x_rtp_tbl(
	p_crt_rtp_tbl	IN rtp_tbl_type,
	p_upd_rtp_tbl	IN rtp_tbl_type,
	x_rtp_tbl	OUT NOCOPY rtp_tbl_type
 ) IS
	crt_idx	NUMBER	:=	0;
	upd_idx	NUMBER	:=	0;
	i	NUMBER	:=	0;

 BEGIN

	IF (p_crt_rtp_tbl.COUNT > 0) THEN
		FOR crt_idx IN p_crt_rtp_tbl.FIRST..p_crt_rtp_tbl.LAST LOOP
		   x_rtp_tbl(i)	:=	p_crt_rtp_tbl(crt_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

	IF (p_upd_rtp_tbl.COUNT > 0) THEN
		FOR upd_idx IN p_upd_rtp_tbl.FIRST..p_upd_rtp_tbl.LAST LOOP
		   x_rtp_tbl(i)	:=	p_upd_rtp_tbl(upd_idx);
		   i	:=	i+1;
		END LOOP;
	END IF;

 END merge_x_rtp_tbl;

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'CREATE_REPORT';
	i	NUMBER	:=	0;
	l_book_class_code	OKL_REPORTS_B.BOOK_CLASSIFICATION_CODE%TYPE;
	l_coa_id	OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE;
	l_report_id	OKL_REPORTS_B.REPORT_ID%TYPE;
	l_func_ret_value	boolean := true;
	la_func_ret_value	boolean := true;
	lt_func_ret_value	boolean := true;
	ls_func_ret_value	boolean := true;
	l_repv_rec	repv_rec_type	:=	p_repv_rec;

	l_rps_tbl	rps_tbl_type	:=	p_rps_tbl;
	l_rpp_tbl	rpp_tbl_type	:=	p_rpp_tbl;
	l_rap_tbl	rap_tbl_type	:=	p_rap_tbl;
	l_rtp_tbl	rtp_tbl_type	:=	p_rtp_tbl;

	l_crt_rpp_tbl	rpp_tbl_type;
	x_crt_rpp_tbl	rpp_tbl_type;
	x_upd_rpp_tbl	rpp_tbl_type;
	x_del_rpp_tbl	rpp_tbl_type;

	l_crt_rtp_tbl	rtp_tbl_type;
	l_upd_rtp_tbl	rtp_tbl_type;
	x_crt_rtp_tbl	rtp_tbl_type;
	x_upd_rtp_tbl	rtp_tbl_type;

 BEGIN
	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	IF (l_repv_rec.effective_from_date IS NULL OR l_repv_rec.effective_from_date = OKL_API.G_MISS_DATE) THEN
		l_repv_rec.effective_from_date	:=	SYSDATE;
	END IF;

	create_report(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		l_repv_rec,
		x_repv_rec);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
		l_book_class_code	:=	x_repv_rec.book_classification_code;
		l_coa_id	:=	x_repv_rec.chart_of_accounts_id;
		l_report_id	:=	x_repv_rec.report_id;
	END IF;

	-- validation calls
	la_func_ret_value	:=	validate_accounts(p_rap_tbl, l_coa_id);
	lt_func_ret_value	:=	validate_transactions(p_rtp_tbl);
	ls_func_ret_value	:=	validate_streams(p_rps_tbl);

	IF (la_func_ret_value = true AND lt_func_ret_value = true AND ls_func_ret_value = true) THEN

		IF (l_rpp_tbl.COUNT > 0) THEN

			FOR i IN l_rpp_tbl.FIRST..l_rpp_tbl.LAST LOOP
			   l_rpp_tbl(i).report_id	:=	l_report_id;
			END LOOP;

			ident_rpp_tbl(
				l_rpp_tbl,
				x_crt_rpp_tbl,
				x_upd_rpp_tbl,
				x_del_rpp_tbl
				);

			l_crt_rpp_tbl	:=	x_crt_rpp_tbl;

			IF (l_crt_rpp_tbl.COUNT > 0) THEN

				create_report_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rpp_tbl,
					x_crt_rpp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;
		END IF;

		IF (l_rap_tbl.COUNT > 0) THEN

			FOR i IN l_rap_tbl.FIRST..l_rap_tbl.LAST LOOP
			   l_rap_tbl(i).report_id	:=	l_report_id;
			END LOOP;

			create_report_acc_parameters(
				p_api_version,
				p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				l_rap_tbl,
				x_rap_tbl);

			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_ERROR;
			END IF;
		END IF;

		IF (l_rps_tbl.COUNT > 0) THEN

			FOR i IN l_rps_tbl.FIRST..l_rps_tbl.LAST LOOP
			   l_rps_tbl(i).report_id	:=	l_report_id;
			END LOOP;

			create_report_strm_parameters(
				p_api_version,
				p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				l_rps_tbl,
				x_rps_tbl);

			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_ERROR;
			END IF;
		END IF;

		IF (l_rtp_tbl.COUNT > 0) THEN

			FOR i IN l_rtp_tbl.FIRST..l_rtp_tbl.LAST LOOP
			   l_rtp_tbl(i).report_id	:=	l_report_id;
			END LOOP;

			ident_rtp_tbl(
				l_rtp_tbl,
				x_crt_rtp_tbl,
				x_upd_rtp_tbl
				);

			l_crt_rtp_tbl	:=	x_crt_rtp_tbl;

			IF (l_crt_rtp_tbl.COUNT <= 0) THEN
				OKL_API.set_message(p_app_name      => G_APP_NAME,
					p_msg_name      => 'OKL_RPP_ONE_TRY_ID_MIN');

				x_return_status :=	OKL_API.G_RET_STS_ERROR;
				RAISE OKL_API.G_EXCEPTION_ERROR;
			ELSE
				create_report_trx_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rtp_tbl,
					x_rtp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

		END IF;
	ELSE
		x_return_status :=	OKL_API.G_RET_STS_ERROR;
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END create_report;

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 ) IS

	l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_name	 VARCHAR2(30)	 :=	'UPDATE_REPORT';
	i	NUMBER	:=	0;
	l_book_class_code	OKL_REPORTS_B.BOOK_CLASSIFICATION_CODE%TYPE;
	l_coa_id	OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE;
	l_func_ret_value	boolean := true;
	la_func_ret_value	boolean := true;
	lt_func_ret_value	boolean := true;
	ls_func_ret_value	boolean := true;
	l_rps_tbl	rps_tbl_type	:=	p_rps_tbl;

	l_crt_rpp_tbl	rpp_tbl_type;
	l_upd_rpp_tbl	rpp_tbl_type;
	l_del_rpp_tbl	rpp_tbl_type;
	x_crt_rpp_tbl	rpp_tbl_type;
	x_upd_rpp_tbl	rpp_tbl_type;
	x_del_rpp_tbl	rpp_tbl_type;

	l_crt_rps_tbl	rps_tbl_type;
	l_upd_rps_tbl	rps_tbl_type;
	x_crt_rps_tbl	rps_tbl_type;
	x_upd_rps_tbl	rps_tbl_type;

	l_crt_rap_tbl	rap_tbl_type;
	l_upd_rap_tbl	rap_tbl_type;
	x_crt_rap_tbl	rap_tbl_type;
	x_upd_rap_tbl	rap_tbl_type;

	l_crt_rtp_tbl	rtp_tbl_type;
	l_upd_rtp_tbl	rtp_tbl_type;
	x_crt_rtp_tbl	rtp_tbl_type;
	x_upd_rtp_tbl	rtp_tbl_type;

 BEGIN

	-- Call start_activity to create savepoint, check compatibility
	-- and initialize message list
	l_return_status := OKL_API.START_ACTIVITY (
				       l_api_name,
				       p_init_msg_list,
				       '_PVT',
				       l_return_status);

	-- Check if activity started successfully
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	update_report(
		p_api_version,
		p_init_msg_list,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_repv_rec,
		x_repv_rec);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
		l_book_class_code	:=	x_repv_rec.book_classification_code;
		l_coa_id	:=	x_repv_rec.chart_of_accounts_id;
	END IF;

	-- validation calls
	la_func_ret_value	:=	validate_accounts(p_rap_tbl, l_coa_id);
	lt_func_ret_value	:=	validate_transactions(p_rtp_tbl);
	ls_func_ret_value	:=	validate_streams(p_rps_tbl);

	IF (la_func_ret_value = true AND lt_func_ret_value = true AND ls_func_ret_value = true) THEN

		IF (p_rpp_tbl.COUNT > 0) THEN

			ident_rpp_tbl(
				p_rpp_tbl,
				x_crt_rpp_tbl,
				x_upd_rpp_tbl,
				x_del_rpp_tbl
				);

			l_crt_rpp_tbl	:=	x_crt_rpp_tbl;
			l_upd_rpp_tbl	:=	x_upd_rpp_tbl;
			l_del_rpp_tbl	:=	x_del_rpp_tbl;

			IF (l_crt_rpp_tbl.COUNT > 0) THEN

				FOR i IN l_crt_rpp_tbl.FIRST..l_crt_rpp_tbl.LAST LOOP
				   l_crt_rpp_tbl(i).report_id	:=	x_repv_rec.report_id;
				END LOOP;

				create_report_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rpp_tbl,
					x_crt_rpp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			IF (l_upd_rpp_tbl.COUNT > 0) THEN

				update_report_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_upd_rpp_tbl,
					x_upd_rpp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			IF (l_del_rpp_tbl.COUNT > 0) THEN

				delete_report_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_del_rpp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			merge_x_rpp_tbl(
				x_crt_rpp_tbl,
				x_upd_rpp_tbl,
				x_rpp_tbl
			);

		END IF;

		IF (p_rap_tbl.COUNT > 0) THEN

			ident_rap_tbl(
				p_rap_tbl,
				x_crt_rap_tbl,
				x_upd_rap_tbl
				);

			l_crt_rap_tbl	:=	x_crt_rap_tbl;
			l_upd_rap_tbl	:=	x_upd_rap_tbl;

			IF (l_crt_rap_tbl.COUNT > 0) THEN

				create_report_acc_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rap_tbl,
					x_crt_rap_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			IF (l_upd_rap_tbl.COUNT > 0) THEN

				update_report_acc_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_upd_rap_tbl,
					x_upd_rap_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			merge_x_rap_tbl(
				x_crt_rap_tbl,
				x_upd_rap_tbl,
				x_rap_tbl
			);

		END IF;

		IF (p_rps_tbl.COUNT > 0) THEN

			ident_rps_tbl(
				l_rps_tbl,
				x_crt_rps_tbl,
				x_upd_rps_tbl
				);

			l_crt_rps_tbl	:=	x_crt_rps_tbl;
			l_upd_rps_tbl	:=	x_upd_rps_tbl;

			IF (l_crt_rps_tbl.COUNT > 0) THEN

				create_report_strm_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rps_tbl,
					x_crt_rps_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			IF (l_upd_rps_tbl.COUNT > 0) THEN

				update_report_strm_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_upd_rps_tbl,
					x_upd_rps_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			merge_x_rps_tbl(
				x_crt_rps_tbl,
				x_upd_rps_tbl,
				x_rps_tbl
			);

		END IF;

		IF (p_rtp_tbl.COUNT > 0) THEN

			ident_rtp_tbl(
				p_rtp_tbl,
				x_crt_rtp_tbl,
				x_upd_rtp_tbl
				);

			l_crt_rtp_tbl	:=	x_crt_rtp_tbl;
			l_upd_rtp_tbl	:=	x_upd_rtp_tbl;

			IF (l_crt_rtp_tbl.COUNT <= 0 AND l_upd_rtp_tbl.COUNT <= 0) THEN

				OKL_API.set_message(p_app_name      => G_APP_NAME,
					p_msg_name      => 'OKL_RPP_ONE_TRY_ID_MIN');

				x_return_status :=	OKL_API.G_RET_STS_ERROR;
				RAISE OKL_API.G_EXCEPTION_ERROR;
			END IF;

			IF (l_crt_rtp_tbl.COUNT > 0) THEN

				create_report_trx_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_crt_rtp_tbl,
					x_crt_rtp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			IF (l_upd_rtp_tbl.COUNT > 0) THEN

				update_report_trx_parameters(
					p_api_version,
					p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_upd_rtp_tbl,
					x_upd_rtp_tbl);

				IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END IF;

			merge_x_rtp_tbl(
				x_crt_rtp_tbl,
				x_upd_rtp_tbl,
				x_rtp_tbl
			);

		END IF;
	ELSE
		x_return_status :=	OKL_API.G_RET_STS_ERROR;
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
				       l_api_name,
				       G_PKG_NAME,
				       'OKL_API.G_RET_STS_ERROR',
				       x_msg_count,
				       x_msg_data,
				       '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OKL_API.G_RET_STS_UNEXP_ERROR',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

    WHEN OTHERS THEN
	    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
				      l_api_name,
				      G_PKG_NAME,
				      'OTHERS',
				      x_msg_count,
				      x_msg_data,
				      '_PVT');

 END update_report;

 PROCEDURE insert_gt(p_contract_number IN okc_k_headers_all_b.contract_number%TYPE,
										p_party_name in hz_parties.party_name%TYPE,
										p_account_number IN hz_cust_accounts.account_number%TYPE ,
										p_cust_site_name IN okx_cust_sites_v.description%TYPE,
										p_inv_msg IN fnd_new_messages.message_text%TYPE,
										p_value IN VARCHAR2

 ) IS
  -------------------------------------------------------------------------------
  -- PROCEDURE insert_gt
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_gt
  -- Description     : Inserts into the global temporary table.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 31-Jan-2007 schodava created.
  -- End of comments
  -------------------------------------------------------------------------------

  BEGIN
		INSERT INTO okl_g_reports_gt
	    (value1_text,
			value2_text,
			value3_text,
			value4_text,
			value5_text,
			value6_text)
			VALUES
			(p_contract_number,
			p_party_name,
			p_account_number,
			p_cust_site_name,
			p_inv_msg,
			p_value);
  END;

  FUNCTION pre_billing
  RETURN BOOLEAN
  -------------------------------------------------------------------------------
  -- FUNCTION pre_billing
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : pre_billing
  -- Description     : Function for Pre Billing Report Generation using
  --                   XML Publisher
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Jan-2007 schodava created.
	-- Following are the validations carried out during pre-billing:
	-- a. Bank account to be used for billing is disabled
	-- b. Payment method to be used for billing is disabled
	-- c. Bill to site to be used for billing is incorrect
	-- d. GL code combination is invalid

  -- HISTORY: 28-Jan-08 schodava Created function
	--          31-Jan-08 schodava Removed sales rep validation,
	--										Inserting GL Concatenated segment value into GT table
	--									  Created a new procedure insert_gt for inserting into gt table
	--										Introduced contract line level bank account validation
	--                    Contract Line Level validation now overrides header level
  -- End of comments
  -------------------------------------------------------------------------------
  IS
    -- Streams cursor
	  CURSOR c_streams IS
      SELECT	stm.khr_id		 khr_id,
				TRUNC (ste.stream_element_date)	bill_date,
				stm.kle_id			 kle_id,
				ste.id				 sel_id,
				stm.sty_id			 sty_id,
				khr.contract_number  contract_number,
				khr.currency_code    currency_code,
				khr.authoring_org_id authoring_org_id,
				sty.name 			 sty_name,
				sty.taxable_default_yn taxable_default_yn,
				ste.amount			 amount,
				khr.sts_code         sts_code,
				khl.pdt_id pdt_id
   	  FROM	OKL_STRM_ELEMENTS		ste,
				OKL_STREAMS			    stm,
				okl_strm_type_v			sty,
				okc_k_headers_b			khr,
				OKL_K_HEADERS			khl,
				okc_k_lines_b			kle,
				okc_statuses_b			khs,
				okc_statuses_b			kls
		  WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		  AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + okl_stream_billing_pvt.get_printing_lead_days(stm.khr_id)))
		  AND ste.amount 			<> 0
		  AND	stm.id				= ste.stm_id
		  AND	ste.date_billed		IS NULL
		  AND	stm.active_yn		= 'Y'
		  AND	stm.say_code		= 'CURR'
		  AND	stm.sty_id = sty.id
		  AND	sty.billable_yn		= 'Y'
		  AND	khr.scs_code		IN ('LEASE', 'LOAN')
      AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED')
		  AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
			AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
			AND khl.id = khr.id
			AND	stm.khr_id = khl.id
			AND	khl.deal_type		IS NOT NULL
			AND	khr.sts_code = khs.code
			AND	khs.ste_code		= 'ACTIVE'
			AND	stm.kle_id = kle.id			(+)
			AND	kle.sts_code = kls.code
			AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED' , 'EXPIRED')
			ORDER BY 1,2,3;

    -- K level Bill to Site
    CURSOR cust_acct_site_csr (cp_khr_id IN NUMBER) IS
      SELECT cs.cust_acct_site_id
			FROM okc_k_headers_v khr
				 , okx_cust_site_uses_v cs
				 , hz_customer_profiles cp
			WHERE khr.id = cp_khr_id
			AND khr.bill_to_site_use_id = cs.id1
			AND khr.bill_to_site_use_id = cp.site_use_id(+);

	-- Customer Account, Org Id cursor
  CURSOR cust_acct_csr(p_khr_id IN  NUMBER) IS
        SELECT cust_acct_id,
				       authoring_org_id
        FROM okc_k_headers_v
        WHERE id = p_khr_id;

  -- Customer Name, Customer Account Number
  CURSOR c_cust_name(cp_cust_acct_id IN NUMBER) IS
	  SELECT name,
		       hca.account_number
		FROM   okx_parties_v hp,
		       hz_cust_accounts hca
		WHERE  hp.id1 = hca.party_id
		AND    hca.cust_account_id = cp_cust_acct_id;

  -- Customer Site Name
	CURSOR c_cust_site_name(cp_cust_acct_site_id IN okx_cust_site_uses_v.cust_acct_site_id%TYPE) IS
	  SELECT description
		FROM   okx_cust_sites_v
		WHERE  cust_acct_site_id = cp_cust_acct_site_id;

  -- K level Payment method
   CURSOR cust_pmth_csr ( p_khr_id IN NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.dnz_chr_id = rgp.chr_id              AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id;

   -- Line Level Payment method
   CURSOR cust_line_pmth_csr ( p_khr_id IN NUMBER,
	                             p_kle_id IN NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.cle_id     = p_kle_id                AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id
        UNION
        SELECT  rul.object1_id1
        FROM okc_k_lines_b cle
            , okc_k_items_v item
            , okc_k_lines_b linked_asset
            , OKC_RULES_B       rul
            , Okc_rule_groups_B rgp
        WHERE cle.dnz_chr_id = p_khr_id                AND
              cle.id = p_kle_id                        AND
              cle.chr_id IS NULL                       AND
              cle.id = item.cle_id                     AND
              item.object1_id1 = linked_asset.id       AND
              linked_asset.id = rgp.cle_id             AND
              linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rgp_id     = rgp.id                  AND
              rul.rule_information_category = 'LAPMTH';

    -- System level Payment Method
    CURSOR rcpt_mthd_csr(p_cust_rct_mthd NUMBER) IS
 	   SELECT c.receipt_method_id,
		        c.name
	   FROM   okx_receipt_methods_v c
	   WHERE  c.id1 = p_cust_rct_mthd;

  -- System Level Payment Method Code
   CURSOR rcpt_method_csr ( p_rct_method_id  NUMBER) IS
	   SELECT C.CREATION_METHOD_CODE
	   FROM  AR_RECEIPT_METHODS M,
       		 AR_RECEIPT_CLASSES C
	   WHERE  M.RECEIPT_CLASS_ID = C.RECEIPT_CLASS_ID AND
	   		  M.receipt_method_id = p_rct_method_id;

	 -- Line level Bill to Site
   CURSOR line_bill_to_csr(p_khr_id IN NUMBER,
	                         p_kle_id IN NUMBER) IS
        SELECT cs.cust_acct_site_id
        FROM okc_k_headers_b khr
           , okx_cust_site_uses_v cs
           , okc_k_lines_b cle
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.chr_id IS NOT NULL
        AND cle.id = p_kle_id
        AND cle.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+)
        UNION
        SELECT cs.cust_acct_site_id
        FROM okc_k_headers_b khr
           , okc_k_lines_b cle
           , okc_k_items item
           , okc_k_lines_b linked_asset
           , okx_cust_site_uses_v cs
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.id = p_kle_id
        AND cle.chr_id IS NULL
        AND cle.id = item.cle_id
        AND item.object1_id1 = linked_asset.id
        AND linked_asset.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+);

      -- Validate customer payment method in AR
			CURSOR validate_cust_pmt_method (cp_customer_id IN ra_cust_receipt_methods.customer_id%TYPE,
																  cp_receipt_method_id IN ra_cust_receipt_methods.receipt_method_id%TYPE,
																	cp_trx_date IN DATE) IS
			SELECT 'X'
           FROM   ra_cust_receipt_methods CPM
           WHERE  cpm.customer_id = cp_customer_id
           AND    cpm.receipt_method_id = cp_receipt_method_id
           AND    cp_trx_date BETWEEN NVL(CPM.START_DATE, cp_trx_date)
                                 AND NVL(CPM.END_DATE, cp_trx_date);

      -- Validate payment method in AR
			CURSOR validate_pmt_method (cp_receipt_method_id IN ra_cust_receipt_methods.receipt_method_id%TYPE,
																	cp_trx_date IN DATE) IS
			SELECT 'X'
           FROM   AR_RECEIPT_METHODS CPM
           WHERE  cpm.receipt_method_id = cp_receipt_method_id
           AND    cp_trx_date BETWEEN NVL(CPM.START_DATE, cp_trx_date)
                                 AND NVL(CPM.END_DATE, cp_trx_date);

		-- Validate Bill to Site in AR
    CURSOR validate_bill_to_site (cp_cust_account_id IN NUMBER)
		IS
		SELECT 'X'
    FROM hz_cust_acct_sites acct_site,
		     hz_cust_site_uses site_use
    WHERE acct_site.cust_account_id = cp_cust_account_id
		AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
		AND site_use.site_use_code = 'BILL_TO'
		AND acct_site.status = 'A'
		AND site_use.status = 'A';

    -- Validate K Level Bank Account in IBY
    CURSOR validate_k_bank_account (cp_khr_id IN okc_k_headers_all_b.id%TYPE) IS
		SELECT DECODE (SIGN ( TRUNC (SYSDATE) - pym_instr.start_date),-1, 'I',
					   DECODE (SIGN ( TRUNC (SYSDATE)- NVL (pym_instr.end_date, TRUNC (SYSDATE))),1, 'I','A')) instr_status,
					 bnk.bank_account_number,
					 DECODE (SIGN ( TRUNC (SYSDATE)- NVL (bnk.start_date, TRUNC (SYSDATE))), -1, 'I',
					   DECODE (SIGN ( TRUNC (SYSDATE)- NVL (bnk.end_date, TRUNC (SYSDATE))), 1, 'I','A')	) bnk_status
		FROM okc_rules_b rul,
				okc_rule_groups_b rgp,
			  iby_pmt_instr_uses_all pym_instr,
				iby_ext_bank_accounts_v bnk
		WHERE rul.rgp_id     = rgp.id
		AND	rgp.rgd_code   = 'LABILL'
		AND	rgp.dnz_chr_id = rgp.chr_id
		AND	rgp.dnz_chr_id = cp_khr_id
		AND	rul.rule_information_category = 'LABACC'
		AND rul.object1_id1 = pym_instr.instrument_payment_use_id
		AND	pym_instr.instrument_id = bnk.bank_account_id
		AND pym_instr.instrument_type = 'BANKACCOUNT';

		-- Derive Line level Bank Account
		CURSOR cust_line_bank_csr ( cp_khr_id NUMBER,
		                            cp_kle_id NUMBER ) IS
					SELECT  object1_id1
					FROM OKC_RULES_B       rul,
							 Okc_rule_groups_B rgp
					WHERE rul.rgp_id     = rgp.id                  AND
								rgp.cle_id     = cp_kle_id                AND
								rgp.rgd_code   = 'LABILL'                AND
								rul.rule_information_category = 'LABACC' AND
								rgp.dnz_chr_id = cp_khr_id
					UNION
					SELECT rul.object1_id1
					FROM okc_k_lines_b cle
							, okc_k_items_v item
							, okc_k_lines_b linked_asset
							, OKC_RULES_B       rul
							, Okc_rule_groups_B rgp
					WHERE cle.dnz_chr_id = cp_khr_id                AND
								cle.id = cp_kle_id                        AND
								cle.chr_id IS NULL                       AND
								cle.id = item.cle_id                     AND
								item.object1_id1 = linked_asset.id       AND
								linked_asset.id = rgp.cle_id             AND
								linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
								rgp.rgd_code   = 'LABILL'                AND
								rul.rgp_id     = rgp.id                  AND
								rul.rule_information_category = 'LABACC';

			-- Validate line level Bank Account in IBY
			CURSOR validate_bank_account (cp_instrument_payment_use_id IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE) IS
			SELECT DECODE (SIGN ( TRUNC (SYSDATE) - pym_instr.start_date),-1, 'I',
							 DECODE (SIGN ( TRUNC (SYSDATE)- NVL (pym_instr.end_date, TRUNC (SYSDATE))),1, 'I','A')) instr_status,
						 bnk.bank_account_number,
						 DECODE (SIGN ( TRUNC (SYSDATE)- NVL (bnk.start_date, TRUNC (SYSDATE))), -1, 'I',
							 DECODE (SIGN ( TRUNC (SYSDATE)- NVL (bnk.end_date, TRUNC (SYSDATE))), 1, 'I','A')	) bnk_status
			FROM iby_pmt_instr_uses_all pym_instr,
					iby_ext_bank_accounts_v bnk
			WHERE pym_instr.instrument_payment_use_id = cp_instrument_payment_use_id
			AND	pym_instr.instrument_id = bnk.bank_account_id
		  AND pym_instr.instrument_type = 'BANKACCOUNT';

    -- Cursor to fetch ccids for the passed product and stream type
		CURSOR c_ccid(cp_sty_id IN  okl_streams.sty_id%TYPE,
							    cp_pdt_id IN okl_k_headers.pdt_id%TYPE) IS
	  SELECT aetl.code_combination_id,
		       glv.concatenated_segments
		FROM 	okl_ae_tmpt_lnes aetl,
					okl_ae_templates aet,
					okl_ae_tmpt_sets  aes,
					okl_products	pdt,
					okl_trx_types_b  trx,
					gl_code_combinations_kfv glv
		WHERE aetl.avl_id = aet.id
			AND aet.aes_id = aes.id
			AND	aes.id = pdt.aes_id
		  AND pdt.id = cp_pdt_id
		  AND aet.sty_id = cp_sty_id
  		AND aet.try_id = trx.id
		  AND trx.aep_code IN ('CREDIT_MEMO', 'BILLING','ADJUSTMENTS')
			AND aetl.code_combination_id = glv.code_combination_id;

    -- Validate GL CCID
		CURSOR c_gl_ccid_valid(cp_ccid IN NUMBER,
											     cp_bill_date IN DATE) IS
		SELECT 'x'
		FROM   gl_code_combinations
		WHERE  code_combination_id = cp_ccid
    AND    enabled_flag = 'Y'
		AND    cp_bill_date BETWEEN NVL(start_date_active,cp_bill_date)
							          AND NVL(end_date_active, cp_bill_date);

		-- cursor c_streams data structure
		TYPE bill_rec_type IS RECORD (
				khr_id                  okc_k_headers_b.id%TYPE,
				bill_date               okl_strm_elements.stream_element_date%TYPE,
				kle_id			        okl_streams.kle_id%TYPE,
				sel_id				    okl_strm_elements.id%TYPE,
				sty_id			        okl_streams.sty_id%TYPE,
				contract_number         okc_k_headers_b.contract_number%TYPE,
				currency_code           okc_k_headers_b.currency_code%TYPE,
				authoring_org_id        okc_k_headers_b.authoring_org_id%TYPE,
				sty_name 			    okl_strm_type_v.NAME%TYPE,
				taxable_default_yn      okl_strm_type_v.taxable_default_yn%TYPE,
				amount			    okl_strm_elements.amount%TYPE,
				sts_code                okc_k_headers_b.sts_code%TYPE,
				pdt_id                  okl_k_headers.pdt_id%TYPE);

		TYPE bill_tbl_type IS TABLE OF bill_rec_type
					INDEX BY BINARY_INTEGER;

    bill_tbl bill_tbl_type;

		l_khr_id												okl_trx_ar_invoices_v.khr_id%TYPE := -1;
		l_bill_date											okl_trx_ar_invoices_v.date_invoiced%TYPE;
		l_kle_id												okl_txl_ar_inv_lns_v.kle_id%TYPE := -1;
		l_auth_org_id										okc_k_headers_all_b.authoring_org_id%TYPE;
		l_pdt_id												okl_products.id%TYPE;
		l_aes_id                        okl_products.aes_id%TYPE;
		l_chart_of_accounts_id					NUMBER;
		l_instr_assignment_id						NUMBER;
		l_ext_receipt_method_name				okx_receipt_methods_v.name%TYPE;
		l_ext_line_receipt_method_name  okx_receipt_methods_v.name%TYPE;
		l_rct_method_code								ar_receipt_classes.creation_method_code%TYPE;
    l_ext_customer_id								Okl_Ext_Sell_Invs_V.customer_id%TYPE;
    l_ext_receipt_method_id					Okl_Ext_Sell_Invs_V.receipt_method_id%TYPE;
    l_party_name										okx_parties_v.name%TYPE;
    l_ext_addr_id										okx_cust_site_uses_v.cust_acct_site_id%TYPE;
		l_cust_site_name								okx_cust_sites_v.description%TYPE;
    l_pmth_id1											okc_rules_b.object1_id1%TYPE;
    l_ext_line_addr_id              okl_ext_sell_invs_v.customer_address_id%TYPE;
    l_pmth_line_id1                 okc_rules_b.object1_id1%TYPE;
    l_ext_line_receipt_method_id    Okl_Ext_Sell_Invs_V.receipt_method_id%TYPE;
    l_rct_line_method_code          ar_receipt_classes.creation_method_code%TYPE;
		l_account_number                hz_cust_accounts.account_number%TYPE;
		l_bank_line_id1                 okc_rules_b.object1_id1%TYPE;

   	l_exists VARCHAR2(1);
    l_fetch_size NUMBER := 5000;

		l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_REPORT_PVT.PRE_BILLING';
		l_debug_enabled       VARCHAR2(10);
		is_debug_procedure_on BOOLEAN;
		is_debug_statement_on BOOLEAN;
		x_errbuf              VARCHAR2(1000);
		x_retcode             NUMBER;

		-- Messages
		l_inv_bank_account_msg fnd_new_messages.message_text%TYPE;
		l_inv_pmt_method_msg fnd_new_messages.message_text%TYPE;
		l_inv_bill_to_site_msg fnd_new_messages.message_text%TYPE;
		l_inv_ccid_msg fnd_new_messages.message_text%TYPE;

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

	  IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin procedure pre_billing_proc');
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    OPEN c_streams;
    LOOP
    -- Clear table contents
    bill_tbl.DELETE;
    FETCH c_streams BULK COLLECT INTO bill_tbl LIMIT l_fetch_size;
    IF bill_tbl.COUNT > 0 THEN
      FOR k IN bill_tbl.FIRST..bill_tbl.LAST LOOP
		    IF l_khr_id <> bill_tbl(k).khr_id
			  OR l_bill_date	<> bill_tbl(k).bill_date THEN

					-- 1,2,3 : Bank account, Payment method and Bill to Site validation

					-- Customer Account Id
					OPEN  cust_acct_csr ( bill_tbl(k).khr_id );
					FETCH cust_acct_csr INTO l_ext_customer_id, l_auth_org_id;
					CLOSE cust_acct_csr;

					-- Customer Name
					OPEN c_cust_name(cp_cust_acct_id => l_ext_customer_id);
          FETCH c_cust_name INTO l_party_name, l_account_number;
					CLOSE c_cust_name;

					-- Customer Account Site
					OPEN  cust_acct_site_csr ( bill_tbl(k).khr_id );
					FETCH cust_acct_site_csr INTO l_ext_addr_id;
					CLOSE cust_acct_site_csr;

					-- Customer Account Site Name
					OPEN c_cust_site_name(cp_cust_acct_site_id => l_ext_addr_id);
					FETCH c_cust_site_name INTO l_cust_site_name;
					CLOSE c_cust_site_name;

          -- Check if Contract Line level details exist,
					-- If yes, then we need to validate only line level details

					-- Fetch Line Level Bill to Site
					OPEN  line_bill_to_csr(bill_tbl(k).khr_id,
					                       bill_tbl(k).kle_id );
					FETCH line_bill_to_csr INTO l_ext_line_addr_id;
					CLOSE line_bill_to_csr;

					-- Note: If line level address exists,
					-- 1. derive the line level payment method
					-- 2. validate the line level bill to site
					-- If line level address and payment method is not null
					-- 1. validate line level payment method
					-- 2. validate line level bank account
					-- If line level address does not exist validate the header level details

					-- If Line Level address exists
					IF l_ext_line_addr_id IS NOT NULL THEN
						-- clear line level address variables
						l_pmth_line_id1              := NULL;
						l_ext_line_receipt_method_id := NULL;
						l_ext_line_receipt_method_name:= NULL;
						l_rct_line_method_code       := NULL;
						l_bank_line_id1              := NULL;

						-- Customer Account Site Name
						OPEN c_cust_site_name(cp_cust_acct_site_id => l_ext_line_addr_id);
						FETCH c_cust_site_name INTO l_cust_site_name;
						CLOSE c_cust_site_name;

						-- Validate Line level Bill to Site
						OPEN validate_bill_to_site(l_ext_line_addr_id);
						FETCH validate_bill_to_site INTO l_exists;
						IF validate_bill_to_site%NOTFOUND THEN
              IF l_khr_id <> bill_tbl(k).khr_id THEN
								fnd_message.set_name('OKL','OKL_INVALID_BILL_TO_SITE');
								l_inv_bill_to_site_msg := fnd_message.get;
									-- insert into gt table
								insert_gt(bill_tbl(k).contract_number,
									l_party_name,
									l_account_number,
									l_cust_site_name,
									l_inv_bill_to_site_msg,
									l_cust_site_name);
							END IF; -- l_khr_id <> bill_tbl(k).khr_id
						END IF; -- validate_bill_to_site%NOTFOUND
						CLOSE validate_bill_to_site;

						--  Line level Payment Method
						OPEN  cust_line_pmth_csr (bill_tbl(k).khr_id,
																			bill_tbl(k).kle_id );
						FETCH cust_line_pmth_csr INTO l_pmth_line_id1;
						CLOSE cust_line_pmth_csr;

						-- Fetch Line Level system payment method
						OPEN  rcpt_mthd_csr( l_pmth_line_id1 );
						FETCH rcpt_mthd_csr INTO l_ext_line_receipt_method_id,
																		 l_ext_line_receipt_method_name;
						CLOSE rcpt_mthd_csr;

            -- If line level payment method is not null,
						-- validate line level payment method and line level bank account
						IF l_ext_line_receipt_method_id IS NOT NULL THEN

							-- Validate Line level payment method
							OPEN validate_cust_pmt_method(l_ext_customer_id,
																			l_ext_line_receipt_method_id,
																			bill_tbl(k).bill_date);
							FETCH validate_cust_pmt_method INTO l_exists;

							OPEN validate_pmt_method(l_ext_line_receipt_method_id,
																			bill_tbl(k).bill_date);
							FETCH validate_pmt_method INTO l_exists;

							IF validate_pmt_method%NOTFOUND OR validate_cust_pmt_method%NOTFOUND THEN
								IF l_khr_id <> bill_tbl(k).khr_id THEN
									fnd_message.set_name('OKL','OKL_INVALID_PMT_METHOD');
									l_inv_pmt_method_msg := fnd_message.get;
									-- insert into gt table
									insert_gt(bill_tbl(k).contract_number,
										l_party_name,
										l_account_number,
										l_cust_site_name,
										l_inv_pmt_method_msg,
										l_ext_line_receipt_method_name);
								END IF; -- l_khr_id <> bill_tbl(k).khr_id
							END IF;  -- validate_pmt_method%NOTFOUND
							CLOSE	validate_pmt_method;
							CLOSE validate_cust_pmt_method;

							-- Fetch Line Level System payment Method code
							OPEN  rcpt_method_csr (l_ext_line_receipt_method_id);
							FETCH rcpt_method_csr INTO l_rct_line_method_code;
							CLOSE rcpt_method_csr;

							-- derive and validate bank account
							IF (l_rct_line_method_code = 'AUTOMATIC') THEN
							   -- fetch line level bank account
                 OPEN cust_line_bank_csr(cp_khr_id => bill_tbl(k).khr_id,
																				 cp_kle_id => bill_tbl(k).kle_id);
								 FETCH cust_line_bank_csr INTO l_bank_line_id1;
								 CLOSE cust_line_bank_csr;

										FOR l_validate_bank_account IN validate_bank_account(cp_instrument_payment_use_id => l_bank_line_id1) LOOP
										-- validate bank account id in iby
											IF l_validate_bank_account.instr_status = 'I' OR l_validate_bank_account.bnk_status = 'I' THEN
												fnd_message.set_name('OKL','OKL_INVALID_BANK_ACCT');
												l_inv_bank_account_msg := fnd_message.get;
												-- insert into gt table
												insert_gt(bill_tbl(k).contract_number,
													l_party_name,
													l_account_number,
													l_cust_site_name,
													l_inv_bank_account_msg,
													l_validate_bank_account.bank_account_number);
											END IF;  -- bank_account.instr_status
										END LOOP;  -- validate_bank_account

							 -- validate line level bank account in IBY

							END IF;

						END IF; -- l_ext_line_receipt_method_id IS NOT NULL

					ELSE -- line level addr id is null, validate header details

						-- Validate K Bill to Site
						OPEN validate_bill_to_site(l_ext_addr_id);
						FETCH validate_bill_to_site INTO l_exists;
						IF validate_bill_to_site%NOTFOUND THEN
							IF l_khr_id <> bill_tbl(k).khr_id THEN
								fnd_message.set_name('OKL','OKL_INVALID_BILL_TO_SITE');
								l_inv_bill_to_site_msg := fnd_message.get;
								-- insert into gt table
								insert_gt(bill_tbl(k).contract_number,
									l_party_name,
									l_account_number,
									l_cust_site_name,
									l_inv_bill_to_site_msg,
									l_cust_site_name);
							END IF; -- l_khr_id <> bill_tbl(k).khr_id
						END IF;  -- validate_bill_to_site%NOTFOUND
						CLOSE validate_bill_to_site;

						-- K level Payment method
						OPEN  cust_pmth_csr ( bill_tbl(k).khr_id );
						FETCH cust_pmth_csr INTO l_pmth_id1;
						CLOSE cust_pmth_csr;

						-- Fetch K system level payment method
						OPEN  rcpt_mthd_csr( l_pmth_id1 );
						FETCH rcpt_mthd_csr INTO l_ext_receipt_method_id,
																		 l_ext_receipt_method_name;
						CLOSE rcpt_mthd_csr;

						-- Validate K level payment method
						OPEN validate_cust_pmt_method(l_ext_customer_id,
																		l_ext_receipt_method_id,
																		bill_tbl(k).bill_date);
						FETCH validate_cust_pmt_method INTO l_exists;

						OPEN validate_pmt_method(l_ext_receipt_method_id,
																		bill_tbl(k).bill_date);
						FETCH validate_pmt_method INTO l_exists;

						IF validate_pmt_method%NOTFOUND OR validate_cust_pmt_method%NOTFOUND THEN
							IF l_khr_id <> bill_tbl(k).khr_id THEN
								fnd_message.set_name('OKL','OKL_INVALID_PMT_METHOD');
								l_inv_pmt_method_msg := fnd_message.get;
								-- insert into gt table
								insert_gt(bill_tbl(k).contract_number,
									l_party_name,
									l_account_number,
									l_cust_site_name,
									l_inv_pmt_method_msg,
									l_ext_receipt_method_name);
							END IF;  -- l_khr_id <> bill_tbl(k).khr_id
						END IF;  -- validate_pmt_method%NOTFOUND
						CLOSE validate_cust_pmt_method;
						CLOSE validate_pmt_method;

						-- Fetch K system level Receipt method code
						OPEN  rcpt_method_csr (l_ext_receipt_method_id);
						FETCH rcpt_method_csr INTO l_rct_method_code;
						CLOSE rcpt_method_csr;

            -- Validate the K level Bank account
						IF (l_rct_method_code = 'AUTOMATIC') THEN
						-- Fetch the instrument assignment id of the K
							FOR l_validate_k_bank_account IN validate_k_bank_account(cp_khr_id => bill_tbl(k).khr_id) LOOP
							-- validate bank account id in iby
								IF l_validate_k_bank_account.instr_status = 'I' OR l_validate_k_bank_account.bnk_status = 'I' THEN
									IF l_khr_id <> bill_tbl(k).khr_id THEN
										fnd_message.set_name('OKL','OKL_INVALID_BANK_ACCT');
										l_inv_bank_account_msg := fnd_message.get;
									  -- insert into gt table
										insert_gt(bill_tbl(k).contract_number,
											l_party_name,
											l_account_number,
											l_cust_site_name,
											l_inv_bank_account_msg,
											l_validate_k_bank_account.bank_account_number);
									END IF; -- l_khr_id <> bill_tbl(k).khr_id
								END IF;  -- bank_account.instr_status
							END LOOP;  -- validate_k_bank_account

						END IF;   -- rct_method_code = AUTOMATIC

					END IF; -- line level addr id is not null

					-- 4. GL code combination is invalid
          FOR l_ccid IN c_ccid(cp_sty_id => bill_tbl(k).sty_id, cp_pdt_id => bill_tbl(k).pdt_id) LOOP

					  -- validate code combination id
						-- check if bill date or sysdate to be used for all cursors with PM
						OPEN c_gl_ccid_valid (cp_ccid => l_ccid.code_combination_id,
																	cp_bill_date => bill_tbl(k).bill_date);
						FETCH c_gl_ccid_valid INTO l_exists;
						IF c_gl_ccid_valid%NOTFOUND THEN
							fnd_message.set_name('OKL','OKL_INVALID_CCID');
							fnd_message.set_token('STREAM_TYPE', bill_tbl(k).sty_name);
							l_inv_ccid_msg := fnd_message.get;
							-- insert into gt table
							insert_gt(bill_tbl(k).contract_number,
								l_party_name,
								l_account_number,
								l_cust_site_name,
								l_inv_ccid_msg,
								l_ccid.concatenated_segments);
						 END IF;
						 CLOSE c_gl_ccid_valid;

				 END LOOP; -- loop a/c ccids

					-- put the context contract into local variables
					l_khr_id 	:= bill_tbl(k).khr_id;
					l_bill_date	:= bill_tbl(k).bill_date;
				END IF;                   -- l_khr_id <> bill_tbl(k).khr_id
				END LOOP;									-- loop a/c bill_tbl
  		END IF;											-- bill_tbl.count > 0
			EXIT WHEN c_streams%NOTFOUND;
     END LOOP;										-- Loop a/c c_streams
		 CLOSE c_streams;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end procedure pre_billing_proc');
   END IF;
   RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;
    RETURN TRUE;
  END pre_billing;

END Okl_Report_Pvt;

/
