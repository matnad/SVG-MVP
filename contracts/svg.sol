pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SVG is ERC721Enumerable {
    using Strings for uint; // Allows to convert uints to strings

    uint public counter;

    string img_name = "On-Chain SVG";
    bool flag; // Determines the background color of the NFT

    constructor() ERC721("SVG-MVP", "SVG") {
    }

    function mint() public {
        _safeMint(msg.sender, ++counter);
    }

    function toggle() public {
        // Switch color between red and green
        flag = !flag;
    }

    function tokenURI(uint tokenId) public view override returns (string memory output) {
        string memory background = flag ? '#00ff00' : '#ff0000'; // flag true -> green, otherwise red

        string memory svg = '<svg height="200" version="1.1" width="400" xmlns="http://www.w3.org/2000/svg">';
        svg = string(abi.encodePacked(svg,
            '<style>',
            'text { font-family: Monospace, Helvetica, sans-serif; font-weight: bold; fill: #444444; font-size: 1em; }',
            '.title { text-anchor: middle; font-size: 1.5em; }',
            '</style>'
        ));
        svg = string(abi.encodePacked(svg, '<rect width="100%" height="100%" fill="', background ,'" />'));
        svg = string(abi.encodePacked(svg, '<text x="200" y="40" class="title">Title: ', img_name, '</text>'));
        svg = string(abi.encodePacked(svg, '<text x="20" y="80">NFT ID: ', tokenId.toString(), '</text>'));
        svg = string(abi.encodePacked(svg, '</svg>'));

        // Generate JSON with SVG image
        output = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "', img_name, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ))))));
    }

}


/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
