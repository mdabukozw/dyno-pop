function copy_link() {
	var byte_link = document.QuerySelector('#paragraph--short-link');
	var byte_copy_button = document.QuerySelector('#button--copy-link');

	/* Select the text field */
	byte_link.select();
	byte_link.setSelectionRange(0, 99999); /* For mobile devices */

	/* Copy the text inside the text field */
	navigator.clipboard.writeText(byte_link.innerText);
	
	/* Change the class to indicate successful copying */
	byte_copy_button.innerText('Copied');
	byte_copy_button.className = 'button u-pull-right'

	/* Alert the copied text */
	alert("Copied the text: " + byte_link.innerText);
}