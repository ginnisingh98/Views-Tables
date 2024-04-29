--------------------------------------------------------
--  DDL for Package OKL_INS_POLICIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_POLICIES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIPYS.pls 120.5 2008/02/29 10:50:31 nikshah ship $ */
/*#
 * Insurance Policy API allows users to perform actions on
 * third party policies in Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Insurance Policy API
 * @rep:category BUSINESS_ENTITY OKL_RISK_MANAGEMENT
 * @rep:lifecycle active
 * @rep:compatibility S
 */


 subtype ipyv_rec_type is okl_ipy_pvt.ipyv_rec_type;
 subtype ipyv_tbl_type is okl_ipy_pvt.ipyv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INS_POLICIES_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------
 PROCEDURE insert_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_tbl                     IN  ipyv_tbl_type
    ,x_ipyv_tbl                     OUT  NOCOPY ipyv_tbl_type);

/*#
 * Create third party insurance policy.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_ipyv_rec  Insurance policy record
 * @param x_ipyv_rec  Insurance policy record
 * @rep:displayname Create Insurance Policy
 * @rep:scope public
 * @rep:lifecycle active
 */
 PROCEDURE insert_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_rec                     IN  ipyv_rec_type
    ,x_ipyv_rec                     OUT  NOCOPY ipyv_rec_type);
 PROCEDURE lock_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_tbl                     IN  ipyv_tbl_type);
 PROCEDURE lock_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_rec                     IN  ipyv_rec_type);
 PROCEDURE update_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_tbl                     IN  ipyv_tbl_type
    ,x_ipyv_tbl                     OUT  NOCOPY ipyv_tbl_type);
 PROCEDURE update_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_rec                     IN  ipyv_rec_type
    ,x_ipyv_rec                     OUT  NOCOPY ipyv_rec_type);
 PROCEDURE delete_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_tbl                     IN  ipyv_tbl_type);
 PROCEDURE delete_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_rec                     IN  ipyv_rec_type);
  PROCEDURE validate_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_tbl                     IN  ipyv_tbl_type);
 PROCEDURE validate_ins_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ipyv_rec                     IN  ipyv_rec_type);
END okl_ins_policies_pub;

/
