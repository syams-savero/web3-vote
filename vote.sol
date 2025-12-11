// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Selamat datang di Backend Web3!
// Ini adalah "Database" dan "API" lu yang abadi.

contract DeVote {
    
    // --- STRUKTUR DATA ---
    
    struct Poll {
        uint256 id;
        string question;    // Pertanyaan: "Siapa Presiden?"
        string[] options;   // Pilihan: ["A", "B", "C"]
        uint256[] votes;    // Jumlah Suara: [0, 0, 0]
        uint256 endTime;    // Kapan voting ditutup (Timestamp)
        address creator;    // Siapa yang bikin (Wallet Address)
    }

    // Gudang penyimpanan semua Poll
    Poll[] public polls;

    // Catatan siapa udah vote di poll mana
    // Mapping: Poll ID => Wallet Address => Sudah Vote? (True/False)
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // --- EVENT (Biar Frontend tau ada kejadian) ---
    event PollCreated(uint256 indexed pollId, string question);
    event Voted(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    // --- FUNGSI UTAMA ---

    // 1. MEMBUAT VOTING BARU
    function createPoll(string memory _question, string[] memory _options, uint256 _durationInMinutes) public {
        require(_options.length > 1, "Minimal harus ada 2 pilihan!");
        
        uint256 pollId = polls.length; // ID otomatis (0, 1, 2...)
        
        // Siapkan array hitungan suara (awalnya 0 semua)
        uint256[] memory initialVotes = new uint256[](_options.length);

        // Masukkan data ke gudang
        polls.push(Poll({
            id: pollId,
            question: _question,
            options: _options,
            votes: initialVotes,
            endTime: block.timestamp + (_durationInMinutes * 1 minutes),
            creator: msg.sender
        }));

        emit PollCreated(pollId, _question);
    }

    // 2. MEMBERIKAN SUARA (VOTE)
    function vote(uint256 _pollId, uint256 _optionIndex) public {
        // Validasi Keamanan (Audit Check)
        require(_pollId < polls.length, "Poll tidak ditemukan!");
        require(block.timestamp < polls[_pollId].endTime, "Voting sudah ditutup!");
        require(!hasVoted[_pollId][msg.sender], "Anda sudah memilih!");
        require(_optionIndex < polls[_pollId].options.length, "Pilihan tidak valid!");

        // Rekam Suara
        polls[_pollId].votes[_optionIndex]++;
        
        // Tandai user ini udah vote (biar gak curang)
        hasVoted[_pollId][msg.sender] = true;

        emit Voted(_pollId, msg.sender, _optionIndex);
    }

    // 3. MELIHAT DATA VOTING
    function getPoll(uint256 _pollId) public view returns (
        string memory question,
        string[] memory options,
        uint256[] memory voteCounts,
        uint256 endTime,
        bool isOpen
    ) {
        require(_pollId < polls.length, "Poll tidak ditemukan!");
        Poll storage p = polls[_pollId];
        
        return (
            p.question,
            p.options,
            p.votes,
            p.endTime,
            block.timestamp < p.endTime // Status apakah masih buka
        );
    }
    
    // 4. HITUNG JUMLAH POLL
    function getPollCount() public view returns (uint256) {
        return polls.length;
    }
}
