// Exact WebAPI routes
class ApiPaths {
	static const String _baseUrl = '/api/GejaKhcAPI/';
	
	// Midib
	static const String listMidibs  = '${_baseUrl}GetMidibList';
	static const String getMidib    = '${_baseUrl}GetMidib';
	static const String setMidib    = '${_baseUrl}SetMidib';
	static const String deleteMidib = '${_baseUrl}DeleteMidib';

	// Member
	static const String listMembersByMidib = '${_baseUrl}GetMemberList';
	static const String getAllMembers      = '${_baseUrl}GetAllMembers';
	static const String getMember          = '${_baseUrl}GetMember';
	static const String setMember          = '${_baseUrl}SetMember';
	static const String deleteMember       = '${_baseUrl}DeleteMember';

	// MembershipMeans
    static const String getMembershipMeans = '${_baseUrl}GetMembershipMeans';
	static const String getMembershipMeansList = '${_baseUrl}GetMembershipMeansList';
	
	// Month
    static const String getMonth = '${_baseUrl}GetMonth';
    static const String getMonthList = '${_baseUrl}GetMonthList';
	
	// Gender
	static const String getGender		= '${_baseUrl}GetGender';
	static const String getGenderList 	= '${_baseUrl}GetGenderList';
	
	// AddressInfo
	static const String getAddressInfo = '${_baseUrl}GetAddressInfo';
	static const String getAddressInfoByMember = '${_baseUrl}GetAddressInfoByMember';
	static const String setAddressInfo = '${_baseUrl}SetAddressInfo';
	static const String getSubcity = '${_baseUrl}GetSubcity';	
	static const String getSubcityList = '${_baseUrl}GetSubcityList';	
	static const String getHouseOwnership = '${_baseUrl}GetHouseOwnershipType';
	static const String getHouseOwnershipList = '${_baseUrl}GetHouseOwnershipTypeList';
	
	// EducationAndJobInfo
	static const String getEducationAndJobInfo = '${_baseUrl}GetEducationAndJobInfo';
	static const String getEducationAndJobInfoByMember = '${_baseUrl}GetEducationAndJobInfoByMember';
	static const String setEducationAndJobInfo = '${_baseUrl}setEducationAndJobInfo';
	static const String getEducationLevel = '${_baseUrl}GetEducationLevel';
	static const String getEducationLevelList = '${_baseUrl}GetEducationLevelList';
	static const String getFieldOfStudy = '${_baseUrl}GetFieldOfStudy';
	static const String getFieldOfStudyList = '${_baseUrl}GetFieldOfStudyList';
	static const String getJob = '${_baseUrl}GetJob';
	static const String getJobList = '${_baseUrl}GetJobList';
	static const String getJobType = '${_baseUrl}GetJobType';
	static const String getJobTypeList = '${_baseUrl}GetJobTypeList';
	
	// FamilyInfo
	static const String getFamilyInfo = '${_baseUrl}GetFamilyInfo';
	static const String getFamilyInfoByMember = '${_baseUrl}GetFamilyInfoByMember';
	static const String setFamilyInfo = '${_baseUrl}SetFamilyInfo';
	static const String getMaritalStatus = '${_baseUrl}GetMaritalStatus';
	static const String getMaritalStatusList = '${_baseUrl}GetMaritalStatusList';
	
	// MemberPhoto
	static const String getMemberPhoto = '${_baseUrl}GetMemberPhoto';
	static const String getMemberPhotoByMember = '${_baseUrl}GetMemberPhotoByMember';
	
	// MemberMinistries
	static const String getMemberMinistry = '${_baseUrl}GetMemberMinistry';
	static const String getMemberMinistriesByMember = '${_baseUrl}GetMemberMinistriesByMember';
	static const String getMinistryType = '${_baseUrl}GetMinistryType';
	static const String getMinistry = '${_baseUrl}GetMinistry';

	// Reports
	static const String getEducationLevelByMidib = '${_baseUrl}GetEducationLevelByMidib';
	static const String getMaritalStatusByMidib  = '${_baseUrl}GetMaritalStatusByMidib';
	static const String getMembershipMeansByMidib= '${_baseUrl}GetMembershipMeansByMidib';
	static const String getSubcityByMidib        = '${_baseUrl}GetSubcityByMidib';
	static const String getGenderByMidib         = '${_baseUrl}GetGenderByMidib';
}