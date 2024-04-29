--------------------------------------------------------
--  DDL for Package OKS_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CHANGE_STATUS_PVT" AUTHID CURRENT_USER as
/* $Header: OKSVCSTS.pls 120.2.12010000.2 2010/01/13 13:11:35 cgopinee ship $ */

/*cgopinee bugfix 9259068*/
 G_HEADER_STATUS_CHANGED VARCHAR2(1):='N';

 subtype chrv_tbl_type is OKC_CONTRACT_PUB.chrv_tbl_type;
 subtype clev_tbl_type is OKC_CONTRACT_PUB.clev_tbl_type;
 subtype control_rec_type is okc_util.okc_control_tbl_type;
 Type Num_Tbl_Type is table of NUMBER index  by BINARY_INTEGER ;
 TYPE VC30_Tbl_Type is TABLE of VARCHAR2(30) index  by BINARY_INTEGER ;
 subtype wf_attr_details is OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;


procedure Update_header_status(x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               p_init_msg_list      in  varchar2 default FND_API.G_FALSE,
                               p_chrv_tbl           in OUT NOCOPY chrv_tbl_type,
                               p_canc_reason_code   in varchar2,
                               p_comments           in varchar2 default FND_API.G_MISS_CHAR,
                               p_term_cancel_source in varchar2 default 'MANUAL',
                               p_date_cancelled     in date default sysdate,
                               p_validate_status    in varchar2 default 'Y');

procedure Update_header_status(x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               p_init_msg_list       in  varchar2 default FND_API.G_FALSE,
                               p_id                 in number,
                               p_new_sts_code       in varchar2,
                               p_canc_reason_code   in varchar2,
                               p_old_sts_code       in varchar2 default FND_API.G_MISS_CHAR,
                               p_comments           in varchar2 default FND_API.G_MISS_CHAR,
                               p_term_cancel_source in varchar2 default 'MANUAL',
                               p_date_cancelled     in date default sysdate,
                               p_validate_status     in varchar2 default 'Y');

procedure Update_line_status ( x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_data            OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              p_init_msg_list       in  varchar2 default FND_API.G_FALSE,
                              p_id                  in number,
                              p_cle_id              in number,
                              p_new_sts_code        in varchar2,
                              p_canc_reason_code    in varchar2,
                              p_old_sts_code        in varchar2 default FND_API.G_MISS_CHAR,
                              p_old_ste_code        in varchar2 default FND_API.G_MISS_CHAR,
                              p_new_ste_code        in varchar2 default FND_API.G_MISS_CHAR,
                              p_term_cancel_source  in varchar2 default 'MANUAL',
                              p_date_cancelled      in Date default sysdate,
                              p_comments            in Varchar2 default FND_API.G_MISS_CHAR,
                              p_validate_status     in varchar2 default 'Y');


procedure VALIDATE_STATUS( x_return_status  out NOCOPY varchar2,
                           x_msg_count      out NOCOPY number,
                           x_msg_data       out NOCOPY varchar2,
                           p_id             in number,
                           p_new_ste_code   in varchar2,
                           p_old_ste_code   in varchar2,
                           p_new_sts_code   in varchar2,
                           p_old_sts_code   in varchar2,
                           p_cle_id         in number,
                           p_validate_status in varchar2 default 'Y');

procedure check_allowed_status( x_return_status     OUT NOCOPY VARCHAR2,
                        x_msg_count         OUT NOCOPY NUMBER,
                        x_msg_data          OUT NOCOPY VARCHAR2,
                        p_id                IN NUMBER,
                        p_cle_id            IN NUMBER,
                        p_new_sts_code      IN VARCHAR2,
                        p_old_sts_code      IN OUT NOCOPY VARCHAR2,
                        p_old_ste_code      IN OUT NOCOPY VARCHAR2,
                        p_new_ste_code      IN OUT NOCOPY VARCHAR2);



Procedure UPDATE_CONTRACT_TAX_AMOUNT(
				    p_api_version       IN NUMBER,
				    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
				    p_id                IN NUMBER,
				    p_from_ste_code     IN VARCHAR2,
				    p_to_ste_code       IN VARCHAR2,
				    p_cle_id            IN NUMBER,
				    x_return_status     OUT NOCOPY VARCHAR2,
				    x_msg_count         OUT NOCOPY NUMBER,
				    x_msg_data          OUT NOCOPY VARCHAR2 );


Procedure UPDATE_SUBSCRIPTION_TAX_AMOUNT(
			p_api_version	IN NUMBER,
			p_init_msg_list IN varchar2 default FND_API.G_FALSE,
			p_id		IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count	OUT NOCOPY NUMBER,
			x_msg_data	OUT NOCOPY VARCHAR2);


function Renewed_YN (p_id in number) return boolean;

function get_source_list (p_id in Number, p_cle_id in Number default FND_API.G_MISS_NUM)
	 return varchar2;

function get_target_list (p_id in number, p_cle_id in number default FND_API.G_MISS_NUM)
	 return varchar2;

function target_cancelled(p_id in number, p_cle_id in number default FND_API.G_MISS_NUM)
	 return boolean;

function Is_Entered (p_id in Number, p_cle_id in Number default FND_API.G_MISS_NUM)
	 return boolean;

function is_not_entered_cancelled (p_id in number, p_cle_id in Number default FND_API.G_MISS_NUM)
	 return boolean;

PROCEDURE populate_table(x_chrv_tbl in out NOCOPY chrv_tbl_type, i in number);

function TARGET_EXISTS(p_id in number, p_cle_id in Number default FND_API.G_MISS_NUM)
	 return boolean;

function get_tax_for_subs_line(p_id in number, p_cle_id in number default FND_API.G_MISS_NUM)
	return number;

end;

/
