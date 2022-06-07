pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract aElection {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        string description;
    }

    struct Elect {
        uint256 id;
        address owner;
        bool expired;
        string question;
        mapping(uint256 => Candidate) candidate_list;
        uint256 canCount;
        address[] voter_List;
        string description;
    }

    // Store Candidates
    // Fetch Candidate
    mapping(uint256 => Elect) public election_info;

    // Store Candidates Count
    uint256 public candidatesCount;
    uint256 public electCount;

    // voted event
    event votedEvent(uint256 indexed _candidateId);

    function aElection() public {
        // create_new_election("Who is the next President of America?","Choose your new President!",["Donald Trump","Joe Biden"],["He is a millionaire","Unkown"]);
        // create_new_election("What is your favourite programming language?","Choose your favourite language!",["Python","JavaScript","PHP"],["Used in Machine Learning and others puposes","Flexible language", "Popular backend language"]);
        addElect("Who is the next President of America?","Choose your new President!");
        addCan("Donald Trump", 1, "He is a millionaire");
        addCan("Joe Biden", 1, "Unknown");

        addElect("What is your favourite programming language?","Choose your favourite language!");
        addCan("Python",2,"Used in Machine Learning and many others puposes");
        addCan("JavaScript",2," A Flexible Language");
        addCan("PHP",2," A Popular Backend Language");

        addElect("Which country do you support?","Which according to you have the Right?");
        addCan("Russia", 3, "Who started the war");
        addCan("Ukraine", 3, "Who has been suffering the domineering from Russia");

        set_expire(2);
    }

    function addCan(
        string memory _name,
        uint256 _electID,
        string memory _description
    ) public {
        election_info[_electID].canCount++;
        uint256 temp = election_info[_electID].canCount;
        election_info[electCount].candidate_list[temp] = Candidate(
            temp,
            _name,
            0,
            _description
        );
    }

    function addElect(string memory _question, string memory _des) public {
        electCount++;
        address[] memory temp;
        election_info[electCount] = Elect(
            electCount,
            msg.sender,
            false,
            _question,
            0,
            temp,
            _des
        );
    }

    function create_new_election(
        string memory _question,
        string memory _electDes,
        string[] memory _name,
        string[] memory _description
    ) public {
        addElect(_question, _electDes);
        for (uint256 i = 0; i < _name.length; i++) {
            addCan(_name[i], electCount, _description[i]);
        }
    }

    function get_list_candidate_of_id(uint256 _electID)
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            uint256[] memory,
            string[] memory
        )
    {
        uint256 candidateConut = election_info[_electID].canCount;
        uint256[] memory id = new uint256[](candidateConut);
        string[] memory name = new string[](candidateConut);
        uint256[] memory amount = new uint256[](candidateConut);
        string[] memory descript = new string[](candidateConut);
        for (uint256 i = 0; i < candidateConut; i++) {
            Candidate storage candidate = election_info[_electID].candidate_list[i+1];
            id[i] = candidate.id;
            name[i] = candidate.name;
            amount[i] = candidate.voteCount;
            descript[i] = candidate.description;
        }

        return (id, name, amount, descript);
    }

    function getTotal(uint256 _electID)
        public
        view
        returns (
            uint256 
        )
    {
        uint256 candidateConut = election_info[_electID].canCount;
        uint256 total;
        for (uint256 i = 0; i < candidateConut; i++) {
            Candidate storage candidate = election_info[_electID].candidate_list[i+1];
            total+= candidate.voteCount;
        }

        return total;
    }

    function getCanCount(uint256 _electID) public view returns (uint256) {
        return election_info[_electID].canCount;
    }

    function get_list_election_count() public view returns (uint256) {
        return electCount;
    }

    function getCanInfo(uint256 _electID, uint256 _canID)
        public
        view
        returns (
            uint256,
            string memory,
            uint256
        )
    {
        Candidate memory temp = election_info[_electID].candidate_list[_canID];
        return (temp.id, temp.name, temp.voteCount);
    }

    function checkIfExist(address _address, address[] _list_address)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < _list_address.length; i++) {
            if (_list_address[i] == _address) return true;
        }
        return false;
    }

    function set_expire(uint256 _electID) public {
        election_info[_electID].expired = true;
    }

    function vote(uint256 _candidateId, uint256 _electID) public {
        // require that they haven't voted before
        bool voted = checkIfExist(
            msg.sender,
            election_info[_electID].voter_List
        );
        require(!voted);

        // require that the election haven't expired
        bool expired = election_info[_electID].expired;
        require(!expired);

        // require a valid candidate
        require(
            _candidateId > 0 && _candidateId <= election_info[_electID].canCount
        );

        // record that voter has voted
        election_info[_electID].voter_List.push(msg.sender);

        // update candidate vote Count
        election_info[_electID].candidate_list[_candidateId].voteCount++;

        // trigger voted event
        votedEvent(_candidateId);
    }

    function check_vote_status(uint _electID)
        public
        view
        returns (bool)
    {
        return checkIfExist(msg.sender, election_info[_electID].voter_List);
    }
    function checkVotedToList()
        public
        view
        returns (bool[] memory)
    {
        bool[] memory voted = new bool[](electCount);
        // for (uint256 i = 0; i < election_info[_electID].voter_List.length; i++) {
        //     if (_list_address[i] == msg.sender) 
        //         voted[i]=true;
        //     else 
        //         voted[i]=false;
        // }
        for(uint256 i=1; i<=electCount; i++){
        //     for (uint256 j = 0; j < election_info[_electID].voter_List.length; j++) {
        //     if (_list_address[i] == msg.sender) 
        //         voted[i]=true;
        //     else 
        //         voted[i]=false;
        // }
            voted[i-1]=check_vote_status(i);
        }
        return voted;
    }

    
}
